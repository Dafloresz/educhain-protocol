// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title EduGovernance (DAO Simplificada)
 * @notice Mecanismo de governança onde holders de EDU votam em propostas
 *         que afetam o protocolo (ex: adicionar cursos, alterar APR, etc).
 *
 * MECÂNICA:
 *  - Qualquer holder com >= PROPOSAL_THRESHOLD tokens pode criar proposta.
 *  - Período de votação: VOTING_PERIOD segundos.
 *  - Quórum mínimo: QUORUM_BPS do supply total.
 *  - Proposta aprovada: maioria simples de votos SIM.
 *  - Após aprovação: timelock de TIMELOCK_DELAY antes de execução.
 *  - Execução: chama address.call(calldata) on-chain (ou sinaliza off-chain).
 *
 * SEGURANÇA:
 *  - ReentrancyGuard em execute.
 *  - Snapshot do supply no momento da criação da proposta.
 *  - Um voto por endereço por proposta.
 *  - Solidity ^0.8.17.
 */
contract EduGovernance is ReentrancyGuard, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    IERC20 public immutable govToken; // EDU token

    uint256 public constant PROPOSAL_THRESHOLD = 1_000  * 1e18;  // 1k EDU
    uint256 public constant VOTING_PERIOD      = 3 days;
    uint256 public constant TIMELOCK_DELAY     = 1 days;
    uint256 public constant QUORUM_BPS         = 400;             // 4% do supply
    uint256 public constant BPS_DENOMINATOR    = 10_000;

    enum ProposalState {
        Pending,    // criada, ainda não votável
        Active,     // em votação
        Defeated,   // quórum não atingido ou maioria contra
        Succeeded,  // aprovada, aguardando timelock
        Queued,     // no timelock
        Executed,   // executada
        Cancelled   // cancelada pelo proponente
    }

    struct Proposal {
        uint256  id;
        address  proposer;
        string   description;
        address  target;       // contrato a chamar (0x0 = sinalização off-chain)
        bytes    callData;     // dados da chamada
        uint256  forVotes;
        uint256  againstVotes;
        uint256  startTime;
        uint256  endTime;
        uint256  supplySnapshot; // supply no momento da criação
        uint256  eta;            // earliest execution time (após timelock)
        bool     executed;
        bool     cancelled;
    }

    uint256 public proposalCount;
    mapping(uint256 => Proposal) public proposals;
    // proposalId => voter => voted?
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    // proposalId => voter => support (true = sim)
    mapping(uint256 => mapping(address => bool)) public voteChoice;

    // ─── Eventos ──────────────────────────────────────────────────────────────
    event ProposalCreated(
        uint256 indexed id,
        address indexed proposer,
        string  description,
        uint256 startTime,
        uint256 endTime
    );
    event VoteCast(
        uint256 indexed proposalId,
        address indexed voter,
        bool    support,
        uint256 weight
    );
    event ProposalQueued(uint256 indexed id, uint256 eta);
    event ProposalExecuted(uint256 indexed id);
    event ProposalCancelled(uint256 indexed id);

    constructor(address _govToken, address admin) {
        require(_govToken != address(0), "Gov: invalid token");
        govToken = IERC20(_govToken);
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
    }

    // ─── Criação de proposta ──────────────────────────────────────────────────

    /**
     * @notice Cria nova proposta de governança.
     * @param description  Texto descritivo da proposta
     * @param target       Contrato alvo (ou address(0) para off-chain)
     * @param callData_    Calldata a executar no contrato alvo
     */
    function propose(
        string calldata description,
        address target,
        bytes calldata callData_
    ) external returns (uint256 proposalId) {
        require(
            govToken.balanceOf(msg.sender) >= PROPOSAL_THRESHOLD,
            "Gov: insufficient tokens to propose"
        );

        proposalId = proposalCount++;
        uint256 start = block.timestamp;
        uint256 end   = start + VOTING_PERIOD;
        uint256 snap  = govToken.totalSupply();

        proposals[proposalId] = Proposal({
            id:              proposalId,
            proposer:        msg.sender,
            description:     description,
            target:          target,
            callData:        callData_,
            forVotes:        0,
            againstVotes:    0,
            startTime:       start,
            endTime:         end,
            supplySnapshot:  snap,
            eta:             0,
            executed:        false,
            cancelled:       false
        });

        emit ProposalCreated(proposalId, msg.sender, description, start, end);
    }

    // ─── Votação ──────────────────────────────────────────────────────────────

    /**
     * @notice Vota em uma proposta. Peso = saldo EDU do voter.
     * @param proposalId ID da proposta
     * @param support    true = SIM, false = NÃO
     */
    function castVote(uint256 proposalId, bool support) external {
        Proposal storage p = proposals[proposalId];
        require(block.timestamp >= p.startTime, "Gov: voting not started");
        require(block.timestamp <= p.endTime,   "Gov: voting ended");
        require(!p.cancelled,                    "Gov: proposal cancelled");
        require(!hasVoted[proposalId][msg.sender], "Gov: already voted");

        uint256 weight = govToken.balanceOf(msg.sender);
        require(weight > 0, "Gov: no voting power");

        hasVoted[proposalId][msg.sender]   = true;
        voteChoice[proposalId][msg.sender] = support;

        if (support) {
            p.forVotes += weight;
        } else {
            p.againstVotes += weight;
        }

        emit VoteCast(proposalId, msg.sender, support, weight);
    }

    // ─── Fila & Execução ──────────────────────────────────────────────────────

    /**
     * @notice Coloca proposta aprovada na fila de timelock.
     */
    function queue(uint256 proposalId) external {
        require(state(proposalId) == ProposalState.Succeeded, "Gov: proposal not succeeded");
        uint256 eta = block.timestamp + TIMELOCK_DELAY;
        proposals[proposalId].eta = eta;
        emit ProposalQueued(proposalId, eta);
    }

    /**
     * @notice Executa proposta após o timelock.
     */
    function execute(uint256 proposalId) external nonReentrant {
        Proposal storage p = proposals[proposalId];
        require(state(proposalId) == ProposalState.Queued, "Gov: not queued");
        require(block.timestamp >= p.eta, "Gov: timelock not expired");

        p.executed = true;

        if (p.target != address(0) && p.callData.length > 0) {
            (bool success, ) = p.target.call(p.callData);
            require(success, "Gov: execution failed");
        }

        emit ProposalExecuted(proposalId);
    }

    /**
     * @notice Cancela proposta (apenas o proponente ou admin).
     */
    function cancel(uint256 proposalId) external {
        Proposal storage p = proposals[proposalId];
        require(
            msg.sender == p.proposer || hasRole(ADMIN_ROLE, msg.sender),
            "Gov: not authorized"
        );
        require(!p.executed, "Gov: already executed");
        p.cancelled = true;
        emit ProposalCancelled(proposalId);
    }

    // ─── Estado da proposta ───────────────────────────────────────────────────

    function state(uint256 proposalId) public view returns (ProposalState) {
        Proposal storage p = proposals[proposalId];

        if (p.cancelled) return ProposalState.Cancelled;
        if (p.executed)  return ProposalState.Executed;

        if (block.timestamp < p.startTime) return ProposalState.Pending;
        if (block.timestamp <= p.endTime)  return ProposalState.Active;

        // Votação encerrada — verifica quórum e maioria
        uint256 quorum = (p.supplySnapshot * QUORUM_BPS) / BPS_DENOMINATOR;
        uint256 totalVotes = p.forVotes + p.againstVotes;

        if (totalVotes < quorum || p.forVotes <= p.againstVotes) {
            return ProposalState.Defeated;
        }

        if (p.eta == 0) return ProposalState.Succeeded;

        return ProposalState.Queued;
    }

    /**
     * @notice Retorna resumo de votação de uma proposta.
     */
    function getVoteSummary(uint256 proposalId)
        external
        view
        returns (
            uint256 forVotes,
            uint256 againstVotes,
            uint256 quorumRequired,
            ProposalState currentState
        )
    {
        Proposal storage p = proposals[proposalId];
        forVotes        = p.forVotes;
        againstVotes    = p.againstVotes;
        quorumRequired  = (p.supplySnapshot * QUORUM_BPS) / BPS_DENOMINATOR;
        currentState    = state(proposalId);
    }
}
