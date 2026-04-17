// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title EduCertificate (CERT)
 * @notice NFT ERC-721 que representa o certificado de conclusão de curso.
 *         Cada token é único e vinculado a um aluno + curso específico.
 * @dev Soulbound opcional: transferência pode ser bloqueada pelo admin.
 */
contract EduCertificate is
    ERC721,
    ERC721URIStorage,
    ERC721Enumerable,
    AccessControl,
    ReentrancyGuard
{
    using Counters for Counters.Counter;

    bytes32 public constant MINTER_ROLE  = keccak256("MINTER_ROLE");
    bytes32 public constant ADMIN_ROLE   = keccak256("ADMIN_ROLE");

    Counters.Counter private _tokenIdCounter;

    // Soulbound: se true, transferências entre carteiras são bloqueadas
    bool public soulbound;

    struct CertificateData {
        address student;
        uint256 courseId;
        uint256 issuedAt;
        string  courseName;
        uint8   grade; // 0–100
    }

    // tokenId => dados do certificado
    mapping(uint256 => CertificateData) public certificates;
    // student => courseId => já emitiu?
    mapping(address => mapping(uint256 => bool)) public hasCertificate;

    event CertificateIssued(
        uint256 indexed tokenId,
        address indexed student,
        uint256 indexed courseId,
        string  courseName,
        uint8   grade
    );

    constructor(address admin, bool _soulbound) ERC721("EduCertificate", "CERT") {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(MINTER_ROLE, admin);
        soulbound = _soulbound;
    }

    /**
     * @notice Emite um certificado NFT para o aluno que concluiu o curso.
     * @param student   Endereço do aluno
     * @param courseId  ID do curso
     * @param courseName Nome legível do curso
     * @param grade     Nota final (0–100)
     * @param tokenURI_ Metadata URI (IPFS/arweave)
     */
    function issueCertificate(
        address student,
        uint256 courseId,
        string calldata courseName,
        uint8  grade,
        string calldata tokenURI_
    ) external onlyRole(MINTER_ROLE) nonReentrant returns (uint256) {
        require(student != address(0), "CERT: invalid student address");
        require(!hasCertificate[student][courseId], "CERT: certificate already issued");
        require(grade <= 100, "CERT: invalid grade");

        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();

        _safeMint(student, tokenId);
        _setTokenURI(tokenId, tokenURI_);

        certificates[tokenId] = CertificateData({
            student:    student,
            courseId:   courseId,
            issuedAt:   block.timestamp,
            courseName: courseName,
            grade:      grade
        });

        hasCertificate[student][courseId] = true;

        emit CertificateIssued(tokenId, student, courseId, courseName, grade);
        return tokenId;
    }

    /**
     * @notice Retorna todos os tokenIds de um aluno.
     */
    function getCertificatesByStudent(address student)
        external
        view
        returns (uint256[] memory)
    {
        uint256 balance = balanceOf(student);
        uint256[] memory ids = new uint256[](balance);
        for (uint256 i = 0; i < balance; i++) {
            ids[i] = tokenOfOwnerByIndex(student, i);
        }
        return ids;
    }

    // ─── Soulbound ────────────────────────────────────────────────────────────

    function setSoulbound(bool _soulbound) external onlyRole(ADMIN_ROLE) {
        soulbound = _soulbound;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize   
    ) internal override(ERC721, ERC721Enumerable) {
        if (soulbound && from != address(0) && to != address(0)) {
            revert("CERT: soulbound token non-transferable");
        }
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // ─── Overrides obrigatórios ────────────────────────────────────────────────

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
