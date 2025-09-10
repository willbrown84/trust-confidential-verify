// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { SepoliaConfig } from "@fhevm/solidity/config/ZamaConfig.sol";
import { euint32, externalEuint32, euint8, ebool, FHE } from "@fhevm/solidity/lib/FHE.sol";

contract TrustConfidentialVerify is SepoliaConfig {
    using FHE for *;
    
    struct VerificationRequest {
        euint32 requestId;
        euint8 verificationStatus; // 0: Pending, 1: Approved, 2: Rejected
        euint8 documentType; // 0: ID, 1: Passport, 2: Driver License, 3: Other
        euint8 riskScore; // 0-100 encrypted risk assessment
        bool isActive;
        string documentHash;
        address requester;
        address verifier;
        uint256 timestamp;
        uint256 expiryTime;
    }
    
    struct KYCRecord {
        euint32 recordId;
        euint8 complianceLevel; // 0: Basic, 1: Enhanced, 2: Premium
        euint8 verificationScore; // 0-100 encrypted verification score
        euint8 riskRating; // 0: Low, 1: Medium, 2: High
        bool isVerified;
        bool isActive;
        string metadataHash;
        address user;
        address verifiedBy;
        uint256 createdAt;
        uint256 lastUpdated;
    }
    
    struct DocumentProof {
        euint32 proofId;
        euint8 authenticityScore; // 0-100 encrypted authenticity score
        euint8 tamperDetection; // 0: No tampering, 1: Tampered
        bool isValid;
        string proofHash;
        address documentOwner;
        uint256 timestamp;
    }
    
    mapping(uint256 => VerificationRequest) public verificationRequests;
    mapping(uint256 => KYCRecord) public kycRecords;
    mapping(uint256 => DocumentProof) public documentProofs;
    mapping(address => euint32) public userReputation;
    mapping(address => euint8) public userTrustLevel;
    
    uint256 public requestCounter;
    uint256 public kycCounter;
    uint256 public proofCounter;
    
    address public owner;
    address public verifierRole;
    address public complianceOfficer;
    
    event VerificationRequested(uint256 indexed requestId, address indexed requester, string documentHash);
    event VerificationCompleted(uint256 indexed requestId, address indexed verifier, uint8 status);
    event KYCCompleted(uint256 indexed recordId, address indexed user, uint8 complianceLevel);
    event DocumentProofCreated(uint256 indexed proofId, address indexed owner, string proofHash);
    event ReputationUpdated(address indexed user, uint32 reputation);
    event TrustLevelUpdated(address indexed user, uint8 trustLevel);
    
    constructor(address _verifierRole, address _complianceOfficer) {
        owner = msg.sender;
        verifierRole = _verifierRole;
        complianceOfficer = _complianceOfficer;
    }
    
    function submitVerificationRequest(
        string memory _documentHash,
        uint256 _expiryTime,
        externalEuint32 documentType,
        bytes calldata inputProof
    ) public returns (uint256) {
        require(bytes(_documentHash).length > 0, "Document hash cannot be empty");
        require(_expiryTime > block.timestamp, "Expiry time must be in the future");
        
        uint256 requestId = requestCounter++;
        
        // Convert externalEuint32 to euint32 using FHE.fromExternal
        euint32 internalDocumentType = FHE.fromExternal(documentType, inputProof);
        
        verificationRequests[requestId] = VerificationRequest({
            requestId: FHE.asEuint32(0), // Will be set properly later
            verificationStatus: FHE.asEuint8(0), // Pending
            documentType: FHE.asEuint8(internalDocumentType),
            riskScore: FHE.asEuint8(50), // Default medium risk
            isActive: true,
            documentHash: _documentHash,
            requester: msg.sender,
            verifier: address(0),
            timestamp: block.timestamp,
            expiryTime: _expiryTime
        });
        
        emit VerificationRequested(requestId, msg.sender, _documentHash);
        return requestId;
    }
    
    function processVerification(
        uint256 _requestId,
        externalEuint32 status,
        externalEuint32 riskScore,
        bytes calldata inputProof
    ) public {
        require(msg.sender == verifierRole || msg.sender == complianceOfficer, "Only authorized verifiers");
        require(verificationRequests[_requestId].requester != address(0), "Request does not exist");
        require(verificationRequests[_requestId].isActive, "Request is not active");
        require(block.timestamp <= verificationRequests[_requestId].expiryTime, "Request has expired");
        
        // Convert external values to internal FHE values
        euint32 internalStatus = FHE.fromExternal(status, inputProof);
        euint32 internalRiskScore = FHE.fromExternal(riskScore, inputProof);
        
        verificationRequests[_requestId].verificationStatus = FHE.asEuint8(internalStatus);
        verificationRequests[_requestId].riskScore = FHE.asEuint8(internalRiskScore);
        verificationRequests[_requestId].verifier = msg.sender;
        verificationRequests[_requestId].isActive = false;
        
        emit VerificationCompleted(_requestId, msg.sender, 0); // Status will be decrypted off-chain
    }
    
    function createKYCRecord(
        string memory _metadataHash,
        externalEuint32 complianceLevel,
        externalEuint32 verificationScore,
        externalEuint32 riskRating,
        bytes calldata inputProof
    ) public returns (uint256) {
        require(bytes(_metadataHash).length > 0, "Metadata hash cannot be empty");
        
        uint256 recordId = kycCounter++;
        
        // Convert external values to internal FHE values
        euint32 internalComplianceLevel = FHE.fromExternal(complianceLevel, inputProof);
        euint32 internalVerificationScore = FHE.fromExternal(verificationScore, inputProof);
        euint32 internalRiskRating = FHE.fromExternal(riskRating, inputProof);
        
        kycRecords[recordId] = KYCRecord({
            recordId: FHE.asEuint32(0), // Will be set properly later
            complianceLevel: FHE.asEuint8(internalComplianceLevel),
            verificationScore: FHE.asEuint8(internalVerificationScore),
            riskRating: FHE.asEuint8(internalRiskRating),
            isVerified: true,
            isActive: true,
            metadataHash: _metadataHash,
            user: msg.sender,
            verifiedBy: verifierRole,
            createdAt: block.timestamp,
            lastUpdated: block.timestamp
        });
        
        emit KYCCompleted(recordId, msg.sender, 0); // Compliance level will be decrypted off-chain
        return recordId;
    }
    
    function createDocumentProof(
        string memory _proofHash,
        externalEuint32 authenticityScore,
        externalEuint32 tamperDetection,
        bytes calldata inputProof
    ) public returns (uint256) {
        require(bytes(_proofHash).length > 0, "Proof hash cannot be empty");
        
        uint256 proofId = proofCounter++;
        
        // Convert external values to internal FHE values
        euint32 internalAuthenticityScore = FHE.fromExternal(authenticityScore, inputProof);
        euint32 internalTamperDetection = FHE.fromExternal(tamperDetection, inputProof);
        
        documentProofs[proofId] = DocumentProof({
            proofId: FHE.asEuint32(0), // Will be set properly later
            authenticityScore: FHE.asEuint8(internalAuthenticityScore),
            tamperDetection: FHE.asEuint8(internalTamperDetection),
            isValid: true,
            proofHash: _proofHash,
            documentOwner: msg.sender,
            timestamp: block.timestamp
        });
        
        emit DocumentProofCreated(proofId, msg.sender, _proofHash);
        return proofId;
    }
    
    function updateUserReputation(
        address user,
        externalEuint32 reputation,
        bytes calldata inputProof
    ) public {
        require(msg.sender == verifierRole || msg.sender == complianceOfficer, "Only authorized verifiers");
        require(user != address(0), "Invalid user address");
        
        euint32 internalReputation = FHE.fromExternal(reputation, inputProof);
        userReputation[user] = internalReputation;
        
        emit ReputationUpdated(user, 0); // Reputation will be decrypted off-chain
    }
    
    function updateUserTrustLevel(
        address user,
        externalEuint32 trustLevel,
        bytes calldata inputProof
    ) public {
        require(msg.sender == verifierRole || msg.sender == complianceOfficer, "Only authorized verifiers");
        require(user != address(0), "Invalid user address");
        
        euint32 internalTrustLevel = FHE.fromExternal(trustLevel, inputProof);
        userTrustLevel[user] = FHE.asEuint8(internalTrustLevel);
        
        emit TrustLevelUpdated(user, 0); // Trust level will be decrypted off-chain
    }
    
    function getVerificationRequestInfo(uint256 _requestId) public view returns (
        uint8 verificationStatus,
        uint8 documentType,
        uint8 riskScore,
        bool isActive,
        string memory documentHash,
        address requester,
        address verifier,
        uint256 timestamp,
        uint256 expiryTime
    ) {
        VerificationRequest storage request = verificationRequests[_requestId];
        return (
            0, // FHE.decrypt(request.verificationStatus) - will be decrypted off-chain
            0, // FHE.decrypt(request.documentType) - will be decrypted off-chain
            0, // FHE.decrypt(request.riskScore) - will be decrypted off-chain
            request.isActive,
            request.documentHash,
            request.requester,
            request.verifier,
            request.timestamp,
            request.expiryTime
        );
    }
    
    function getKYCRecordInfo(uint256 _recordId) public view returns (
        uint8 complianceLevel,
        uint8 verificationScore,
        uint8 riskRating,
        bool isVerified,
        bool isActive,
        string memory metadataHash,
        address user,
        address verifiedBy,
        uint256 createdAt,
        uint256 lastUpdated
    ) {
        KYCRecord storage record = kycRecords[_recordId];
        return (
            0, // FHE.decrypt(record.complianceLevel) - will be decrypted off-chain
            0, // FHE.decrypt(record.verificationScore) - will be decrypted off-chain
            0, // FHE.decrypt(record.riskRating) - will be decrypted off-chain
            record.isVerified,
            record.isActive,
            record.metadataHash,
            record.user,
            record.verifiedBy,
            record.createdAt,
            record.lastUpdated
        );
    }
    
    function getDocumentProofInfo(uint256 _proofId) public view returns (
        uint8 authenticityScore,
        uint8 tamperDetection,
        bool isValid,
        string memory proofHash,
        address documentOwner,
        uint256 timestamp
    ) {
        DocumentProof storage proof = documentProofs[_proofId];
        return (
            0, // FHE.decrypt(proof.authenticityScore) - will be decrypted off-chain
            0, // FHE.decrypt(proof.tamperDetection) - will be decrypted off-chain
            proof.isValid,
            proof.proofHash,
            proof.documentOwner,
            proof.timestamp
        );
    }
    
    function getUserReputation(address user) public view returns (uint32) {
        return 0; // FHE.decrypt(userReputation[user]) - will be decrypted off-chain
    }
    
    function getUserTrustLevel(address user) public view returns (uint8) {
        return 0; // FHE.decrypt(userTrustLevel[user]) - will be decrypted off-chain
    }
    
    function revokeVerificationRequest(uint256 _requestId) public {
        require(verificationRequests[_requestId].requester == msg.sender, "Only requester can revoke");
        require(verificationRequests[_requestId].isActive, "Request is not active");
        
        verificationRequests[_requestId].isActive = false;
    }
    
    function deactivateKYCRecord(uint256 _recordId) public {
        require(kycRecords[_recordId].user == msg.sender, "Only record owner can deactivate");
        require(kycRecords[_recordId].isActive, "Record is not active");
        
        kycRecords[_recordId].isActive = false;
        kycRecords[_recordId].lastUpdated = block.timestamp;
    }
    
    function invalidateDocumentProof(uint256 _proofId) public {
        require(documentProofs[_proofId].documentOwner == msg.sender, "Only proof owner can invalidate");
        require(documentProofs[_proofId].isValid, "Proof is already invalid");
        
        documentProofs[_proofId].isValid = false;
    }
    
    function setVerifierRole(address _newVerifier) public {
        require(msg.sender == owner, "Only owner can set verifier role");
        require(_newVerifier != address(0), "Invalid verifier address");
        
        verifierRole = _newVerifier;
    }
    
    function setComplianceOfficer(address _newOfficer) public {
        require(msg.sender == owner, "Only owner can set compliance officer");
        require(_newOfficer != address(0), "Invalid officer address");
        
        complianceOfficer = _newOfficer;
    }
}
