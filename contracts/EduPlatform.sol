// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./EduToken.sol";
import "./EduCertificate.sol";
import "./EduCourse.sol";

/**
 * @title EduPlatform
 * @notice Contrato orquestrador da plataforma EduChain.
 *         Integra EduToken (ERC-20), EduCertificate (ERC-721) e EduCourse (ERC-1155).
 *
 * FLUXO PRINCIPAL:
 *  1. Admin cria curso via EduCourse.createCourse()
 *  2. Aluno chama enrollStudent() → recebe token ERC-1155 de inscrição
 *  3. Backend/Admin chama completeCourse() → emite NFT ERC-721 (certificado)
 *     + badge ERC-1155 + recompensa EDU (ERC-20)
 *
 * SEGURANÇA:
 *  - ReentrancyGuard nas funções de mint/transfer
 *  - Pausable para emergências
 *  - AccessControl estrito
 */
contract EduPlatform is AccessControl, ReentrancyGuard, Pausable {
    bytes32 public constant ADMIN_ROLE    = keccak256("ADMIN_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    EduToken       public immutable eduToken;
    EduCertificate public immutable certificate;
    EduCourse      public immutable course;

    // Recompensa base em EDU por conclusão de curso (em wei)
    uint256 public completionReward = 100 * 1e18; // 100 EDU

    event StudentEnrolled(address indexed student, uint256 indexed courseId);
    event CourseCompleted(
        address indexed student,
        uint256 indexed courseId,
        uint256 certTokenId,
        uint256 rewardAmount
    );
    event CompletionRewardUpdated(uint256 newReward);

    constructor(
        address _eduToken,
        address _certificate,
        address _course,
        address admin
    ) {
        require(_eduToken     != address(0), "Platform: invalid token");
        require(_certificate  != address(0), "Platform: invalid certificate");
        require(_course       != address(0), "Platform: invalid course");

        eduToken    = EduToken(_eduToken);
        certificate = EduCertificate(_certificate);
        course      = EduCourse(_course);

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(OPERATOR_ROLE, admin);
    }

    /**
     * @notice Matricula um aluno no curso (chama EduCourse.enroll).
     * @param student   Endereço do aluno
     * @param courseId  ID do curso
     */
    function enrollStudent(address student, uint256 courseId)
        external
        onlyRole(OPERATOR_ROLE)
        nonReentrant
        whenNotPaused
    {
        course.enroll(courseId, student);
        emit StudentEnrolled(student, courseId);
    }

    /**
     * @notice Registra conclusão do curso, emite certificado ERC-721,
     *         badge ERC-1155 e recompensa EDU ERC-20.
     *
     * @param student       Endereço do aluno
     * @param courseId      ID do curso
     * @param courseName    Nome do curso
     * @param grade         Nota final (0–100)
     * @param metadataURI   URI do metadata do certificado (IPFS)
     */
    function completeCourse(
        address student,
        uint256 courseId,
        string calldata courseName,
        uint8   grade,
        string calldata metadataURI
    )
        external
        onlyRole(OPERATOR_ROLE)
        nonReentrant
        whenNotPaused
        returns (uint256 certTokenId)
    {
        require(grade >= 60, "Platform: minimum grade not met (60)");

        // 1. Marca conclusão no ERC-1155 + emite badge
        course.completeCourse(courseId, student);

        // 2. Emite certificado ERC-721
        certTokenId = certificate.issueCertificate(
            student,
            courseId,
            courseName,
            grade,
            metadataURI
        );

        // 3. Recompensa em EDU ERC-20 (proporcional à nota)
        uint256 reward = _calculateReward(grade);
        if (reward > 0) {
            eduToken.mint(student, reward);
        }

        emit CourseCompleted(student, courseId, certTokenId, reward);
    }

    /**
     * @notice Recompensa proporcional à nota: 60–69 = 60%, 70–89 = 80%, 90–100 = 100%
     */
    function _calculateReward(uint8 grade) internal view returns (uint256) {
        if (grade >= 90) return completionReward;
        if (grade >= 70) return (completionReward * 80) / 100;
        return (completionReward * 60) / 100;
    }

    function setCompletionReward(uint256 newReward) external onlyRole(ADMIN_ROLE) {
        completionReward = newReward;
        emit CompletionRewardUpdated(newReward);
    }

    function pause()   external onlyRole(ADMIN_ROLE) { _pause(); }
    function unpause() external onlyRole(ADMIN_ROLE) { _unpause(); }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
