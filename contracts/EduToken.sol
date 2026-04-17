// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title EduToken (EDU)
 * @notice Token ERC-20 de recompensa para alunos da plataforma EduChain.
 *         Emitido como recompensa por completar cursos e via staking.
 * @dev Utiliza OpenZeppelin v4. Controle de acesso via AccessControl.
 */
contract EduToken is ERC20, ERC20Burnable, AccessControl, Pausable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    uint256 public constant MAX_SUPPLY = 100_000_000 * 10 ** 18; // 100M EDU

    event TokensMinted(address indexed to, uint256 amount);

    constructor(address admin) ERC20("EduToken", "EDU") {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MINTER_ROLE, admin);
        _grantRole(PAUSER_ROLE, admin);
    }

    /**
     * @notice Emite novos tokens EDU. Apenas endereços com MINTER_ROLE.
     * @param to Destinatário dos tokens
     * @param amount Quantidade (em wei)
     */
    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        require(totalSupply() + amount <= MAX_SUPPLY, "EduToken: max supply exceeded");
        _mint(to, amount);
        emit TokensMinted(to, amount);
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }
}
