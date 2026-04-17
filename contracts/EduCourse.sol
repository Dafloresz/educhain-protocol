// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title EduCourse (ERC-1155)
 * @notice Token multi-tipo que representa inscrições e materiais de cursos.
 *         - IDs pares  (0, 2, 4...): tokens fungíveis de inscrição por curso
 *         - IDs ímpares (1, 3, 5...): NFT de material exclusivo / badge
 * @dev Justificativa ERC-1155:
 *      Um único contrato gerencia TODOS os cursos. Cada curso tem seu próprio
 *      token de inscrição (fungível) e badge exclusivo (não-fungível).
 *      Reduz gas, simplifica deploy e permite transferências em lote.
 */
contract EduCourse is ERC1155, ERC1155Supply, AccessControl, ReentrancyGuard {
    bytes32 public constant ADMIN_ROLE  = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    struct Course {
        string  name;
        string  description;
        uint256 enrollmentTokenId; // fungível – token de inscrição
        uint256 badgeTokenId;      // não-fungível – badge de conclusão
        uint256 price;             // preço em EDU tokens (0 = grátis)
        bool    active;
        address instructor;
        uint256 enrolledCount;
    }

    uint256 public courseCount;
    mapping(uint256 => Course) public courses;
    // courseId => aluno => matriculado?
    mapping(uint256 => mapping(address => bool)) public enrolled;
    // courseId => aluno => concluído?
    mapping(uint256 => mapping(address => bool)) public completed;

    event CourseCreated(uint256 indexed courseId, string name, address instructor);
    event StudentEnrolled(uint256 indexed courseId, address indexed student);
    event CourseCompleted(uint256 indexed courseId, address indexed student);

    constructor(address admin, string memory baseURI_)
        ERC1155(baseURI_)
    {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(MINTER_ROLE, admin);
    }

    /**
     * @notice Cria um novo curso com seus dois tokens ERC-1155.
     */
    function createCourse(
        string calldata name,
        string calldata description,
        uint256 price,
        address instructor
    ) external onlyRole(ADMIN_ROLE) returns (uint256 courseId) {
        courseId = courseCount++;

        // IDs dos tokens: enrollment = courseId*2, badge = courseId*2+1
        uint256 enrollmentId = courseId * 2;
        uint256 badgeId      = courseId * 2 + 1;

        courses[courseId] = Course({
            name:             name,
            description:      description,
            enrollmentTokenId: enrollmentId,
            badgeTokenId:     badgeId,
            price:            price,
            active:           true,
            instructor:       instructor,
            enrolledCount:    0
        });

        emit CourseCreated(courseId, name, instructor);
    }

    /**
     * @notice Matricula um aluno no curso e emite token de inscrição.
     */
    function enroll(uint256 courseId, address student)
        external
        onlyRole(MINTER_ROLE)
        nonReentrant
    {
        Course storage c = courses[courseId];
        require(c.active, "EduCourse: course not active");
        require(!enrolled[courseId][student], "EduCourse: already enrolled");

        enrolled[courseId][student] = true;
        c.enrolledCount++;

        // Mint token fungível de inscrição (supply = 1 por aluno)
        _mint(student, c.enrollmentTokenId, 1, "");

        emit StudentEnrolled(courseId, student);
    }

    /**
     * @notice Marca o curso como concluído e emite badge NFT.
     */
    function completeCourse(uint256 courseId, address student)
        external
        onlyRole(MINTER_ROLE)
        nonReentrant
    {
        require(enrolled[courseId][student], "EduCourse: not enrolled");
        require(!completed[courseId][student], "EduCourse: already completed");

        completed[courseId][student] = true;

        // Mint badge não-fungível (supply = 1, único)
        _mint(student, courses[courseId].badgeTokenId, 1, "");

        emit CourseCompleted(courseId, student);
    }

    function setURI(string memory newUri) external onlyRole(ADMIN_ROLE) {
        _setURI(newUri);
    }

    function setCourseStatus(uint256 courseId, bool active)
        external
        onlyRole(ADMIN_ROLE)
    {
        courses[courseId].active = active;
    }

    // ─── Overrides obrigatórios ────────────────────────────────────────────────

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
