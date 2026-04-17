// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @title EduStaking
 * @notice Contrato de staking de tokens EDU com recompensa ajustada pelo preço
 *         ETH/USD via Chainlink Price Feed.
 *
 * MECÂNICA:
 *  - Alunos fazem stake de EDU tokens para ganhar mais EDU ao longo do tempo.
 *  - A taxa base é BASE_APR (ex: 12% ao ano).
 *  - Se o preço do ETH subir acima de ETH_PRICE_THRESHOLD, um bônus de
 *    BONUS_BPS é aplicado (incentivo de mercado).
 *  - Proteção contra reentrancy em todas as funções de estado.
 *
 * SEGURANÇA:
 *  - ReentrancyGuard em withdraw e claimRewards.
 *  - SafeERC20 para transferências seguras.
 *  - Controle de acesso por ADMIN_ROLE.
 *  - Solidity ^0.8.17 (overflow protection nativa).
 */
contract EduStaking is ReentrancyGuard, AccessControl, Pausable {
    using SafeERC20 for IERC20;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    IERC20  public immutable eduToken;
    AggregatorV3Interface public immutable priceFeed; // Chainlink ETH/USD

    // Parâmetros de recompensa
    uint256 public constant BASE_APR          = 1200;  // 12.00% em bps
    uint256 public constant BONUS_BPS         = 300;   // +3.00% bônus em bps
    uint256 public constant BPS_DENOMINATOR   = 10_000;
    uint256 public constant SECONDS_PER_YEAR  = 365 days;
    uint256 public constant ETH_PRICE_THRESHOLD = 2_500 * 1e8; // $2.500 (8 dec Chainlink)
    uint256 public constant LOCK_PERIOD       = 7 days;  // período mínimo de lock

    struct StakeInfo {
        uint256 amount;
        uint256 stakedAt;
        uint256 lastClaimedAt;
        uint256 rewardDebt; // recompensas acumuladas ainda não sacadas
    }

    mapping(address => StakeInfo) public stakes;
    uint256 public totalStaked;

    // Pool de recompensas depositado pelo admin
    uint256 public rewardPool;

    // ─── Eventos ──────────────────────────────────────────────────────────────
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 reward);
    event RewardPoolFunded(uint256 amount);
    event ParametersUpdated(uint256 threshold);

    constructor(
        address _eduToken,
        address _priceFeed,
        address admin
    ) {
        require(_eduToken   != address(0), "Staking: invalid token");
        require(_priceFeed  != address(0), "Staking: invalid price feed");

        eduToken  = IERC20(_eduToken);
        priceFeed = AggregatorV3Interface(_priceFeed);

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
    }

    // ─── Oráculo ──────────────────────────────────────────────────────────────

    /**
     * @notice Busca o preço atual de ETH/USD via Chainlink.
     * @return price com 8 decimais
     */
    function getEthUsdPrice() public view returns (uint256 price) {
        (, int256 answer,, uint256 updatedAt,) = priceFeed.latestRoundData();
        require(answer > 0, "Staking: invalid oracle price");
        require(block.timestamp - updatedAt <= 1 hours, "Staking: stale oracle");
        price = uint256(answer);
    }

    /**
     * @notice Calcula o APR efetivo com base no preço do ETH.
     * @return apr em basis points
     */
    function effectiveApr() public view returns (uint256 apr) {
        uint256 ethPrice = getEthUsdPrice();
        apr = BASE_APR;
        if (ethPrice >= ETH_PRICE_THRESHOLD) {
            apr += BONUS_BPS;
        }
    }

    // ─── Staking ──────────────────────────────────────────────────────────────

    /**
     * @notice Deposita tokens EDU no contrato de staking.
     * @param amount Quantidade de EDU (em wei)
     */
    function stake(uint256 amount) external nonReentrant whenNotPaused {
        require(amount > 0, "Staking: amount must be > 0");

        StakeInfo storage info = stakes[msg.sender];

        // Coleta recompensas pendentes antes de adicionar mais stake
        if (info.amount > 0) {
            uint256 pending = _calculatePendingReward(msg.sender);
            info.rewardDebt += pending;
        }

        info.amount       += amount;
        info.stakedAt      = info.stakedAt == 0 ? block.timestamp : info.stakedAt;
        info.lastClaimedAt = block.timestamp;
        totalStaked       += amount;

        eduToken.safeTransferFrom(msg.sender, address(this), amount);

        emit Staked(msg.sender, amount);
    }

    /**
     * @notice Retira tokens após o período de lock.
     * @param amount Quantidade de EDU a retirar
     */
    function withdraw(uint256 amount) external nonReentrant whenNotPaused {
        StakeInfo storage info = stakes[msg.sender];
        require(info.amount >= amount, "Staking: insufficient staked amount");
        require(
            block.timestamp >= info.stakedAt + LOCK_PERIOD,
            "Staking: tokens still locked"
        );

        // Coleta recompensas pendentes
        uint256 pending = _calculatePendingReward(msg.sender);
        info.rewardDebt  += pending;
        info.lastClaimedAt = block.timestamp;
        info.amount       -= amount;
        totalStaked       -= amount;

        if (info.amount == 0) {
            info.stakedAt = 0;
        }

        eduToken.safeTransfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }

    /**
     * @notice Saca as recompensas acumuladas de staking.
     */
    function claimRewards() external nonReentrant whenNotPaused {
        StakeInfo storage info = stakes[msg.sender];
        require(info.amount > 0, "Staking: no active stake");

        uint256 pending  = _calculatePendingReward(msg.sender);
        uint256 total    = info.rewardDebt + pending;
        require(total > 0, "Staking: no rewards to claim");
        require(rewardPool >= total, "Staking: reward pool insufficient");

        info.rewardDebt    = 0;
        info.lastClaimedAt = block.timestamp;
        rewardPool        -= total;

        eduToken.safeTransfer(msg.sender, total);

        emit RewardClaimed(msg.sender, total);
    }

    /**
     * @notice Retorna as recompensas pendentes de um usuário.
     */
    function pendingRewards(address user) external view returns (uint256) {
        return _calculatePendingReward(user) + stakes[user].rewardDebt;
    }

    // ─── Interno ──────────────────────────────────────────────────────────────

    function _calculatePendingReward(address user)
        internal
        view
        returns (uint256)
    {
        StakeInfo storage info = stakes[user];
        if (info.amount == 0) return 0;

        uint256 elapsed = block.timestamp - info.lastClaimedAt;
        uint256 apr     = effectiveApr();

        // reward = principal * apr * elapsed / (SECONDS_PER_YEAR * BPS_DENOMINATOR)
        return (info.amount * apr * elapsed) / (SECONDS_PER_YEAR * BPS_DENOMINATOR);
    }

    // ─── Admin ────────────────────────────────────────────────────────────────

    /**
     * @notice Deposita tokens no pool de recompensas.
     */
    function fundRewardPool(uint256 amount) external onlyRole(ADMIN_ROLE) {
        eduToken.safeTransferFrom(msg.sender, address(this), amount);
        rewardPool += amount;
        emit RewardPoolFunded(amount);
    }

    function pause()   external onlyRole(ADMIN_ROLE) { _pause(); }
    function unpause() external onlyRole(ADMIN_ROLE) { _unpause(); }
}
