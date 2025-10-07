# NounsBridge

> **Cross-chain governance bridge connecting NDA token holders on Base to Lil Nouns DAO on Ethereum Mainnet**

![NounsBridge](https://img.shields.io/badge/Phase-1-blue) ![Solidity](https://img.shields.io/badge/Solidity-0.8.20-orange) ![License](https://img.shields.io/badge/License-MIT-green)

## 🎯 Overview

This project replaces the off-chain Snapshot voting system with a fully on-chain governance bridge. NDA token holders can vote on Base, and votes are automatically cast on Ethereum Mainnet through a delegated executor contract.

### What's Changing
- **Old:** Off-chain Snapshot spaces + GitHub Actions relays + Gnosis Safe casting votes
- **New:** Two smart contracts (Base + Ethereum) connected via Layer-0 messaging

## 🏗️ Architecture

### Chains & Contracts

**Base (L2)**
- `MirrorGovernor.sol` - Mirrors Lil Nouns proposals and runs NDA token holder votes
- Receives proposals, manages voting, finalizes results
- Sends Layer-0 messages to Mainnet Executor

**Ethereum Mainnet (L1)**
- `MainnetExecutor.sol` - Holds delegated Lil Nouns voting power
- Receives verified Layer-0 messages from Base
- Casts votes on Lil Nouns Governor (Compound Bravo fork)

### Flow
1. **Mirror**: Lil Nouns proposal is mirrored to Base MirrorGovernor
2. **Vote**: NDA holders vote on Base during proposal window
3. **Finalize**: MirrorGovernor finalizes result on Base
4. **Execute**: Layer-0 message triggers MainnetExecutor to cast vote on Ethereum

## 🛠️ Tech Stack

- **Smart Contracts**: Solidity ^0.8.20
- **Framework**: Hardhat
- **Testing**: Hardhat + Foundry
- **Messaging**: Layer-0 v2 OApp

## 📁 Project Structure

```
nounsbridge/
├── contracts/          # Solidity smart contracts
│   └── interfaces/     # Contract interfaces
├── scripts/            # Deployment and utility scripts
├── test/              # Contract tests
├── docs/              # Documentation
├── README.md          # This file
├── SCOPE.md           # Detailed project scope
├── ROADMAP.md         # Development roadmap
└── UI-UX.md           # Frontend design specifications
```

## 🚀 Quick Start

### Prerequisites
- Node.js v18+
- npm or yarn
- Git

### Installation

```bash
# Clone repository
git clone https://github.com/BaD-DAO/nouns-bridge.git
cd nouns-bridge

# Install dependencies
npm install

# Compile contracts
npx hardhat compile

# Run tests
npx hardhat test
```

## 🧪 Testing

```bash
# Run all tests
npx hardhat test

# Run with coverage
npx hardhat coverage

# Run fork tests (requires RPC URLs)
npx hardhat test --network hardhat
```

## 📋 Deployment

See [ROADMAP.md](./ROADMAP.md) for deployment plan and milestones.

## 🔐 Security

- Layer-0 v2 OApp with multi-DVN verification
- Pausable contracts with emergency controls
- Proxy-based upgradability (UUPS)
- Replay protection on cross-chain messages

## 📖 Documentation

- [SCOPE.md](./SCOPE.md) - Detailed technical scope
- [ROADMAP.md](./ROADMAP.md) - Development phases and timeline
- [UI-UX.md](./UI-UX.md) - Frontend design specifications
- [.cursor-prompt.md](./.cursor-prompt.md) - Cursor AI system prompt
- [docs/](./docs) - Additional technical documentation

## 🤝 Contributing

This project is developed by the BaD DAO team. For questions or contributions, please open an issue or PR.

## 📄 License

MIT License - see LICENSE file for details.

## 🔗 Links

- [Lil Nouns DAO](https://lilnouns.wtf)
- [NDA (Nouns DAO Africa)](https://nda.africa)
- [Layer-0 Documentation](https://layerzero.network)

---

**Status**: Phase 1 Development
**Last Updated**: 2025-10-08
