import { expect } from "chai";
import { ethers, upgrades } from "hardhat";
import { MainnetExecutor } from "../typechain-types";
import { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";

describe("MainnetExecutor", function () {
  let mainnetExecutor: MainnetExecutor;
  let owner: SignerWithAddress;
  let user1: SignerWithAddress;
  let lilNounsGovernor: string;
  let lzEndpoint: string;
  let baseMirrorGovernor: string;

  const BASE_CHAIN_ID = 8453; // Base mainnet
  const PROPOSAL_ID = 1;
  const SUPPORT_FOR = 1;
  const REASON = "Voting from Base via Layer-0";

  beforeEach(async function () {
    [owner, user1] = await ethers.getSigners();

    // Mock addresses
    lilNounsGovernor = await ethers.Wallet.createRandom().getAddress();
    lzEndpoint = await ethers.Wallet.createRandom().getAddress();
    baseMirrorGovernor = await ethers.Wallet.createRandom().getAddress();

    const MainnetExecutor = await ethers.getContractFactory("MainnetExecutor");
    mainnetExecutor = await upgrades.deployProxy(
      MainnetExecutor,
      [lilNounsGovernor, lzEndpoint, baseMirrorGovernor, BASE_CHAIN_ID],
      { initializer: "initialize" }
    ) as unknown as MainnetExecutor;

    await mainnetExecutor.waitForDeployment();
  });

  describe("Initialization", function () {
    it("Should set the correct Lil Nouns Governor", async function () {
      expect(await mainnetExecutor.lilNounsGovernor()).to.equal(lilNounsGovernor);
    });

    it("Should set the correct Layer-0 endpoint", async function () {
      expect(await mainnetExecutor.lzEndpoint()).to.equal(lzEndpoint);
    });

    it("Should set the correct Base MirrorGovernor", async function () {
      expect(await mainnetExecutor.baseMirrorGovernor()).to.equal(baseMirrorGovernor);
    });

    it("Should set the correct Base chain ID", async function () {
      expect(await mainnetExecutor.baseChainId()).to.equal(BASE_CHAIN_ID);
    });

    it("Should set the correct owner", async function () {
      expect(await mainnetExecutor.owner()).to.equal(owner.address);
    });
  });

  describe("Vote Execution", function () {
    it("Should execute vote manually", async function () {
      // TODO: Mock Lil Nouns Governor responses
      // This test will fail until proper mocking is implemented
    });

    it("Should prevent double execution", async function () {
      // TODO: Implement test with proper mocking
    });

    it("Should receive and execute Layer-0 message", async function () {
      // TODO: Implement test with Layer-0 message simulation
    });
  });

  describe("Idempotency", function () {
    it("Should prevent voting on same proposal twice", async function () {
      // TODO: Implement test
    });

    it("Should track executed proposals", async function () {
      // TODO: Implement test
    });
  });

  describe("Admin Functions", function () {
    it("Should allow owner to update governor", async function () {
      const newGovernor = await ethers.Wallet.createRandom().getAddress();

      await expect(mainnetExecutor.setGovernor(newGovernor))
        .to.emit(mainnetExecutor, "GovernorUpdated")
        .withArgs(lilNounsGovernor, newGovernor);

      expect(await mainnetExecutor.lilNounsGovernor()).to.equal(newGovernor);
    });

    it("Should allow owner to update Base MirrorGovernor", async function () {
      const newMirrorGovernor = await ethers.Wallet.createRandom().getAddress();

      await expect(mainnetExecutor.setBaseMirrorGovernor(newMirrorGovernor))
        .to.emit(mainnetExecutor, "BaseMirrorGovernorUpdated")
        .withArgs(baseMirrorGovernor, newMirrorGovernor);

      expect(await mainnetExecutor.baseMirrorGovernor()).to.equal(newMirrorGovernor);
    });

    it("Should allow owner to pause", async function () {
      await mainnetExecutor.pause();
      expect(await mainnetExecutor.paused()).to.be.true;
    });

    it("Should allow owner to unpause", async function () {
      await mainnetExecutor.pause();
      await mainnetExecutor.unpause();
      expect(await mainnetExecutor.paused()).to.be.false;
    });

    it("Should prevent non-owner from pausing", async function () {
      await expect(
        mainnetExecutor.connect(user1).pause()
      ).to.be.reverted;
    });
  });

  describe("View Functions", function () {
    it("Should check if proposal is executed", async function () {
      expect(await mainnetExecutor.isExecuted(PROPOSAL_ID)).to.be.false;
    });

    it("Should get proposal details", async function () {
      // TODO: Mock Lil Nouns Governor to return proposal data
    });

    it("Should get vote receipt", async function () {
      // TODO: Mock Lil Nouns Governor to return receipt data
    });
  });
});
