import { expect } from "chai";
import { ethers, upgrades } from "hardhat";
import { MirrorGovernor } from "../typechain-types";
import { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";

describe("MirrorGovernor", function () {
  let mirrorGovernor: MirrorGovernor;
  let owner: SignerWithAddress;
  let voter1: SignerWithAddress;
  let voter2: SignerWithAddress;
  let votingToken: string;
  let lzEndpoint: string;
  let mainnetExecutor: string;

  const QUORUM_BPS = 2000; // 20%
  const PROPOSAL_ID = 1;
  const START_BLOCK = 100;
  const END_BLOCK = 200;

  beforeEach(async function () {
    [owner, voter1, voter2] = await ethers.getSigners();

    // Mock addresses
    votingToken = await ethers.Wallet.createRandom().getAddress();
    lzEndpoint = await ethers.Wallet.createRandom().getAddress();
    mainnetExecutor = await ethers.Wallet.createRandom().getAddress();

    const MirrorGovernor = await ethers.getContractFactory("MirrorGovernor");
    mirrorGovernor = await upgrades.deployProxy(
      MirrorGovernor,
      [votingToken, QUORUM_BPS, lzEndpoint, mainnetExecutor],
      { initializer: "initialize" }
    ) as unknown as MirrorGovernor;

    await mirrorGovernor.waitForDeployment();
  });

  describe("Initialization", function () {
    it("Should set the correct voting token", async function () {
      expect(await mirrorGovernor.votingToken()).to.equal(votingToken);
    });

    it("Should set the correct quorum", async function () {
      expect(await mirrorGovernor.quorumBps()).to.equal(QUORUM_BPS);
    });

    it("Should set the correct owner", async function () {
      expect(await mirrorGovernor.owner()).to.equal(owner.address);
    });
  });

  describe("Proposal Mirroring", function () {
    it("Should mirror a proposal", async function () {
      await expect(
        mirrorGovernor.mirrorProposal(PROPOSAL_ID, START_BLOCK, END_BLOCK)
      )
        .to.emit(mirrorGovernor, "ProposalMirrored")
        .withArgs(PROPOSAL_ID, START_BLOCK, END_BLOCK);

      const proposal = await mirrorGovernor.proposals(PROPOSAL_ID);
      expect(proposal.id).to.equal(PROPOSAL_ID);
      expect(proposal.startBlock).to.equal(START_BLOCK);
      expect(proposal.endBlock).to.equal(END_BLOCK);
    });

    it("Should revert if proposal already mirrored", async function () {
      await mirrorGovernor.mirrorProposal(PROPOSAL_ID, START_BLOCK, END_BLOCK);

      await expect(
        mirrorGovernor.mirrorProposal(PROPOSAL_ID, START_BLOCK, END_BLOCK)
      ).to.be.revertedWith("Proposal already mirrored");
    });

    it("Should revert if not owner", async function () {
      await expect(
        mirrorGovernor.connect(voter1).mirrorProposal(PROPOSAL_ID, START_BLOCK, END_BLOCK)
      ).to.be.reverted;
    });
  });

  describe("Voting", function () {
    beforeEach(async function () {
      await mirrorGovernor.mirrorProposal(PROPOSAL_ID, START_BLOCK, END_BLOCK);
    });

    it("Should allow casting a vote", async function () {
      // TODO: Mock voting power and block number
      // This test will fail until voting power logic is implemented
    });

    it("Should prevent double voting", async function () {
      // TODO: Implement test
    });

    it("Should correctly tally votes", async function () {
      // TODO: Implement test
    });
  });

  describe("Finalization", function () {
    it("Should finalize a succeeded proposal", async function () {
      // TODO: Implement test
    });

    it("Should prevent finalizing before voting ends", async function () {
      // TODO: Implement test
    });
  });

  describe("Admin Functions", function () {
    it("Should allow owner to update quorum", async function () {
      const newQuorum = 3000;
      await expect(mirrorGovernor.setQuorum(newQuorum))
        .to.emit(mirrorGovernor, "QuorumUpdated")
        .withArgs(QUORUM_BPS, newQuorum);

      expect(await mirrorGovernor.quorumBps()).to.equal(newQuorum);
    });

    it("Should allow owner to pause", async function () {
      await mirrorGovernor.pause();
      expect(await mirrorGovernor.paused()).to.be.true;
    });

    it("Should allow owner to unpause", async function () {
      await mirrorGovernor.pause();
      await mirrorGovernor.unpause();
      expect(await mirrorGovernor.paused()).to.be.false;
    });
  });
});
