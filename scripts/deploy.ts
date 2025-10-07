import { ethers, upgrades } from "hardhat";

/**
 * NounsBridge Deployment Script
 *
 * Deploys MirrorGovernor (Base) and MainnetExecutor (Ethereum)
 * with UUPS upgradeable proxy pattern
 */

async function main() {
  console.log("🚀 Starting NounsBridge deployment...\n");

  const [deployer] = await ethers.getSigners();
  const network = await ethers.provider.getNetwork();

  console.log("Deploying contracts with account:", deployer.address);
  console.log("Account balance:", (await ethers.provider.getBalance(deployer.address)).toString());
  console.log("Network:", network.name, `(${network.chainId})\n`);

  // Configuration
  const config = getNetworkConfig(network.chainId);

  if (network.chainId === 8453n || network.chainId === 84532n) {
    // Deploy on Base (Mainnet or Sepolia)
    await deployMirrorGovernor(config);
  } else if (network.chainId === 1n || network.chainId === 11155111n) {
    // Deploy on Ethereum (Mainnet or Sepolia)
    await deployMainnetExecutor(config);
  } else {
    throw new Error(`Unsupported network: ${network.chainId}`);
  }

  console.log("\n✅ Deployment complete!");
}

async function deployMirrorGovernor(config: any) {
  console.log("📦 Deploying MirrorGovernor on Base...\n");

  const MirrorGovernor = await ethers.getContractFactory("MirrorGovernor");

  const mirrorGovernor = await upgrades.deployProxy(
    MirrorGovernor,
    [
      config.votingToken,
      config.quorumBps,
      config.lzEndpoint,
      config.mainnetExecutor
    ],
    {
      initializer: "initialize",
      kind: "uups"
    }
  );

  await mirrorGovernor.waitForDeployment();
  const address = await mirrorGovernor.getAddress();

  console.log("✅ MirrorGovernor deployed to:", address);
  console.log("   - Implementation:", await upgrades.erc1967.getImplementationAddress(address));
  console.log("   - Admin:", await upgrades.erc1967.getAdminAddress(address));

  // Save deployment info
  saveDeployment("MirrorGovernor", address, config);
}

async function deployMainnetExecutor(config: any) {
  console.log("📦 Deploying MainnetExecutor on Ethereum...\n");

  const MainnetExecutor = await ethers.getContractFactory("MainnetExecutor");

  const mainnetExecutor = await upgrades.deployProxy(
    MainnetExecutor,
    [
      config.lilNounsGovernor,
      config.lzEndpoint,
      config.baseMirrorGovernor,
      config.baseChainId
    ],
    {
      initializer: "initialize",
      kind: "uups"
    }
  );

  await mainnetExecutor.waitForDeployment();
  const address = await mainnetExecutor.getAddress();

  console.log("✅ MainnetExecutor deployed to:", address);
  console.log("   - Implementation:", await upgrades.erc1967.getImplementationAddress(address));
  console.log("   - Admin:", await upgrades.erc1967.getAdminAddress(address));

  // Save deployment info
  saveDeployment("MainnetExecutor", address, config);

  console.log("\n⚠️  IMPORTANT: Delegate Lil Nouns voting power to:", address);
}

function getNetworkConfig(chainId: bigint) {
  // Base Mainnet
  if (chainId === 8453n) {
    return {
      votingToken: process.env.NDA_TOKEN_ADDRESS || "",
      quorumBps: 2000, // 20%
      lzEndpoint: "0x1a44076050125825900e736c501f859c50fE728c",
      mainnetExecutor: process.env.MAINNET_EXECUTOR_ADDRESS || "",
    };
  }

  // Base Sepolia
  if (chainId === 84532n) {
    return {
      votingToken: process.env.NDA_TOKEN_ADDRESS_TESTNET || "",
      quorumBps: 2000,
      lzEndpoint: "0x6EDCE65403992e310A62460808c4b910D972f10f",
      mainnetExecutor: process.env.MAINNET_EXECUTOR_ADDRESS_TESTNET || "",
    };
  }

  // Ethereum Mainnet
  if (chainId === 1n) {
    return {
      lilNounsGovernor: "0x5d2C31ce16924C2a71D317e5BbFd5ce387854039",
      lzEndpoint: "0x1a44076050125825900e736c501f859c50fE728c",
      baseMirrorGovernor: process.env.BASE_MIRROR_GOVERNOR_ADDRESS || "",
      baseChainId: 8453,
    };
  }

  // Ethereum Sepolia
  if (chainId === 11155111n) {
    return {
      lilNounsGovernor: process.env.LIL_NOUNS_GOVERNOR_TESTNET || "",
      lzEndpoint: "0x6EDCE65403992e310A62460808c4b910D972f10f",
      baseMirrorGovernor: process.env.BASE_MIRROR_GOVERNOR_ADDRESS_TESTNET || "",
      baseChainId: 84532,
    };
  }

  throw new Error(`No config for chain ${chainId}`);
}

function saveDeployment(contractName: string, address: string, config: any) {
  const fs = require("fs");
  const path = require("path");

  const deploymentData = {
    contractName,
    address,
    timestamp: new Date().toISOString(),
    config,
    network: process.env.HARDHAT_NETWORK || "unknown"
  };

  const deploymentsDir = path.join(__dirname, "../deployments");
  if (!fs.existsSync(deploymentsDir)) {
    fs.mkdirSync(deploymentsDir, { recursive: true });
  }

  const filename = path.join(deploymentsDir, `${contractName}-${Date.now()}.json`);
  fs.writeFileSync(filename, JSON.stringify(deploymentData, null, 2));

  console.log(`   - Deployment saved to: ${filename}`);
}

// Execute deployment
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
