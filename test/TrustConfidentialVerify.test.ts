import { expect } from "chai";
import { ethers } from "hardhat";

describe("TrustConfidentialVerify", function () {
  let contract: any;
  let owner: any;
  let verifier: any;
  let complianceOfficer: any;
  let user: any;

  beforeEach(async function () {
    [owner, verifier, complianceOfficer, user] = await ethers.getSigners();

    const TrustConfidentialVerify = await ethers.getContractFactory("TrustConfidentialVerify");
    contract = await TrustConfidentialVerify.deploy(verifier.address, complianceOfficer.address);
    await contract.waitForDeployment();
  });

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      expect(await contract.owner()).to.equal(owner.address);
    });

    it("Should set the right verifier role", async function () {
      expect(await contract.verifierRole()).to.equal(verifier.address);
    });

    it("Should set the right compliance officer", async function () {
      expect(await contract.complianceOfficer()).to.equal(complianceOfficer.address);
    });
  });

  describe("Verification Request", function () {
    it("Should allow users to submit verification requests", async function () {
      const documentHash = "0x1234567890abcdef";
      const expiryTime = Math.floor(Date.now() / 1000) + 3600; // 1 hour from now

      // Note: In a real test, you would need to provide proper FHE inputs
      // This is a simplified test for the basic functionality
      await expect(
        contract.submitVerificationRequest(
          documentHash,
          expiryTime,
          "0x0000000000000000000000000000000000000000000000000000000000000001", // documentType = 1
          "0x" // inputProof placeholder
        )
      ).to.emit(contract, "VerificationRequested");
    });

    it("Should reject empty document hash", async function () {
      const expiryTime = Math.floor(Date.now() / 1000) + 3600;

      await expect(
        contract.submitVerificationRequest(
          "",
          expiryTime,
          "0x0000000000000000000000000000000000000000000000000000000000000001",
          "0x"
        )
      ).to.be.revertedWith("Document hash cannot be empty");
    });

    it("Should reject past expiry time", async function () {
      const documentHash = "0x1234567890abcdef";
      const pastTime = Math.floor(Date.now() / 1000) - 3600; // 1 hour ago

      await expect(
        contract.submitVerificationRequest(
          documentHash,
          pastTime,
          "0x0000000000000000000000000000000000000000000000000000000000000001",
          "0x"
        )
      ).to.be.revertedWith("Expiry time must be in the future");
    });
  });

  describe("Access Control", function () {
    it("Should only allow owner to set verifier role", async function () {
      const newVerifier = user.address;

      await expect(
        contract.connect(user).setVerifierRole(newVerifier)
      ).to.be.revertedWith("Only owner can set verifier role");

      await expect(
        contract.connect(owner).setVerifierRole(newVerifier)
      ).to.not.be.reverted;
    });

    it("Should only allow owner to set compliance officer", async function () {
      const newOfficer = user.address;

      await expect(
        contract.connect(user).setComplianceOfficer(newOfficer)
      ).to.be.revertedWith("Only owner can set compliance officer");

      await expect(
        contract.connect(owner).setComplianceOfficer(newOfficer)
      ).to.not.be.reverted;
    });
  });

  describe("KYC Record", function () {
    it("Should allow creation of KYC records", async function () {
      const metadataHash = "0xabcdef1234567890";

      // Note: In a real test, you would need to provide proper FHE inputs
      await expect(
        contract.createKYCRecord(
          metadataHash,
          "0x0000000000000000000000000000000000000000000000000000000000000001", // complianceLevel = 1
          "0x0000000000000000000000000000000000000000000000000000000000000080", // verificationScore = 80
          "0x0000000000000000000000000000000000000000000000000000000000000000", // riskRating = 0
          "0x" // inputProof placeholder
        )
      ).to.emit(contract, "KYCCompleted");
    });

    it("Should reject empty metadata hash", async function () {
      await expect(
        contract.createKYCRecord(
          "",
          "0x0000000000000000000000000000000000000000000000000000000000000001",
          "0x0000000000000000000000000000000000000000000000000000000000000080",
          "0x0000000000000000000000000000000000000000000000000000000000000000",
          "0x"
        )
      ).to.be.revertedWith("Metadata hash cannot be empty");
    });
  });

  describe("Document Proof", function () {
    it("Should allow creation of document proofs", async function () {
      const proofHash = "0x9876543210fedcba";

      // Note: In a real test, you would need to provide proper FHE inputs
      await expect(
        contract.createDocumentProof(
          proofHash,
          "0x0000000000000000000000000000000000000000000000000000000000000095", // authenticityScore = 95
          "0x0000000000000000000000000000000000000000000000000000000000000000", // tamperDetection = 0
          "0x" // inputProof placeholder
        )
      ).to.emit(contract, "DocumentProofCreated");
    });

    it("Should reject empty proof hash", async function () {
      await expect(
        contract.createDocumentProof(
          "",
          "0x0000000000000000000000000000000000000000000000000000000000000095",
          "0x0000000000000000000000000000000000000000000000000000000000000000",
          "0x"
        )
      ).to.be.revertedWith("Proof hash cannot be empty");
    });
  });
});
