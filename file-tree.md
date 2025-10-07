# File Tree: NounsBridge

**Last Updated**: 2025-10-08

---

## 📁 Project Structure

```
nda-lilnouns-bridge/
├── 📄 .env.example                # Environment variables template
├── 📄 .gitignore                  # Git ignore rules
├── 📄 README.md                   # Project overview and quick start
├── 📄 SCOPE.md                    # Detailed technical scope and requirements
├── 📄 ROADMAP.md                  # Development roadmap and milestones
├── 📄 UI-UX.md                    # Frontend design specifications
├── 📄 task-log.md                 # Task tracking and progress
├── 📄 dev-notes.md                # Technical implementation notes
├── 📄 file-tree.md                # This file - project structure
├── 📄 package.json                # Node.js dependencies and scripts
├── 📄 tsconfig.json               # TypeScript configuration
├── 📄 hardhat.config.ts           # Hardhat configuration (multi-chain)
│
├── 📂 contracts/                  # Solidity smart contracts
│   ├── 📄 MirrorGovernor.sol      # Base L2 voting contract
│   ├── 📄 MainnetExecutor.sol     # Ethereum L1 executor contract
│   └── 📂 interfaces/
│       └── 📄 ICompoundBravoLike.sol  # Lil Nouns Governor interface
│
├── 📂 test/                       # Contract tests (TypeScript)
│   ├── 📄 MirrorGovernor.test.ts  # MirrorGovernor unit tests
│   └── 📄 MainnetExecutor.test.ts # MainnetExecutor unit tests
│
├── 📂 scripts/                    # Deployment and utility scripts
│   └── (empty - to be added)
│
└── 📂 docs/                       # Additional documentation
    └── (empty - to be added)
```

---

## 📄 File Descriptions

### Root Configuration Files

#### .cursor-prompt.md
- **Purpose**: Cursor AI system prompt for project-specific context
- **Contents**: Development guidelines, code style, task management templates
- **Used by**: Cursor IDE for AI-assisted development
- **Size**: ~10 KB

#### .env.example
- **Purpose**: Template for environment variables
- **Contents**: RPC URLs, API keys, contract addresses
- **Usage**: Copy to `.env` and fill in actual values
- **Security**: Never commit actual `.env` file
- **Size**: ~1 KB

#### .gitignore
- **Purpose**: Specify files to exclude from git
- **Contents**: node_modules, .env, build artifacts, IDE files
- **Size**: ~500 B

#### package.json
- **Purpose**: Node.js project configuration
- **Contents**: Dependencies, scripts, project metadata
- **Key Dependencies**:
  - Hardhat, OpenZeppelin, Layer-0, ethers.js
- **Scripts**: compile, test, deploy, verify
- **Size**: ~1.5 KB

#### tsconfig.json
- **Purpose**: TypeScript compiler configuration
- **Contents**: Target, module, paths, includes
- **Used by**: Tests, scripts, Hardhat tasks
- **Size**: ~700 B

#### hardhat.config.ts
- **Purpose**: Hardhat framework configuration
- **Contents**:
  - Solidity version (0.8.20)
  - Network configurations (Base, Ethereum, testnets)
  - Etherscan API keys for verification
  - Gas reporter settings
- **Size**: ~2 KB

---

### Documentation Files

#### README.md
- **Purpose**: Project overview and quick start guide
- **Contents**:
  - What's changing (old vs new)
  - Architecture overview
  - Tech stack
  - Installation and testing instructions
  - Links to detailed docs
- **Audience**: Developers, users, auditors
- **Size**: ~4 KB

#### SCOPE.md
- **Purpose**: Detailed technical scope and requirements
- **Contents**:
  - Project objectives
  - Contract deliverables (MirrorGovernor, MainnetExecutor, Interface)
  - Governance parameters
  - Security model
  - Testing requirements
  - Success criteria
- **Audience**: Developers, auditors, stakeholders
- **Size**: ~8 KB

#### ROADMAP.md
- **Purpose**: Development roadmap and milestones
- **Contents**:
  - Phase 1: Foundation & Core Contracts (Weeks 1-4)
  - Phase 2: Deployment & Integration (Weeks 5-6)
  - Phase 3: Frontend Development (Weeks 7-9)
  - Phase 4: Mainnet Launch (Week 10)
  - Risk mitigation strategies
- **Audience**: Team, stakeholders, community
- **Size**: ~7.5 KB

#### UI-UX.md
- **Purpose**: Frontend design specifications
- **Contents**:
  - Design principles and visual identity
  - Page layouts (Proposals, Detail, History)
  - Component library
  - Responsive design
  - Accessibility requirements
- **Audience**: Frontend developers, designers
- **Size**: ~22 KB

#### task-log.md
- **Purpose**: Task tracking and progress monitoring
- **Contents**:
  - Current tasks with status (🔴🟡🟢⭕️🔵✅)
  - Technical debt
  - Blockers and issues
  - Next steps
- **Used by**: Development team, Cursor AI
- **Updated**: Continuously during development
- **Size**: ~5 KB

#### dev-notes.md
- **Purpose**: Technical implementation details
- **Contents**:
  - System architecture diagrams
  - Smart contract details
  - Layer-0 integration notes
  - Configuration parameters
  - Testing strategy
  - Deployment checklist
  - Security considerations
- **Audience**: Developers, auditors
- **Size**: ~12 KB

#### file-tree.md
- **Purpose**: Project structure and file relationships
- **Contents**: This document
- **Audience**: Developers, contributors
- **Size**: ~6 KB

---

### Smart Contracts

#### contracts/MirrorGovernor.sol
- **Purpose**: Base L2 contract for mirroring proposals and managing voting
- **Type**: Upgradeable (UUPS)
- **Key Features**:
  - Proposal mirroring
  - NDA token holder voting
  - Quorum checking
  - Vote finalization
  - Layer-0 OApp sender (TODO)
- **Dependencies**:
  - OpenZeppelin Upgradeable
  - Layer-0 v2 SDK (TODO)
- **Size**: ~12 KB / ~376 LOC
- **Test Coverage**: 30% (in progress)

#### contracts/MainnetExecutor.sol
- **Purpose**: Ethereum L1 contract for executing votes on Lil Nouns Governor
- **Type**: Upgradeable (UUPS)
- **Key Features**:
  - Layer-0 OApp receiver (TODO)
  - Vote execution on Lil Nouns Governor
  - Idempotency checks
  - Delegation validation (TODO)
- **Dependencies**:
  - OpenZeppelin Upgradeable
  - ICompoundBravoLike interface
  - Layer-0 v2 SDK (TODO)
- **Size**: ~10 KB / ~319 LOC
- **Test Coverage**: 25% (in progress)

#### contracts/interfaces/ICompoundBravoLike.sol
- **Purpose**: Interface for Lil Nouns Governor (Compound Bravo fork)
- **Type**: Interface
- **Key Functions**:
  - castVote, castVoteWithReason
  - proposals, getActions, getReceipt
  - proposalThreshold, quorumVotes
- **Dependencies**: None
- **Size**: ~4 KB / ~125 LOC
- **Used by**: MainnetExecutor.sol

---

### Test Files

#### test/MirrorGovernor.test.ts
- **Purpose**: Unit tests for MirrorGovernor contract
- **Framework**: Hardhat + Chai
- **Test Suites**:
  - ✅ Initialization
  - ✅ Proposal mirroring
  - ❌ Voting (needs mocking)
  - ❌ Finalization
  - ✅ Admin functions
- **Size**: ~3 KB / ~120 LOC
- **Status**: Scaffolding complete

#### test/MainnetExecutor.test.ts
- **Purpose**: Unit tests for MainnetExecutor contract
- **Framework**: Hardhat + Chai
- **Test Suites**:
  - ✅ Initialization
  - ❌ Vote execution (needs mocking)
  - ❌ Layer-0 message handling
  - ❌ Idempotency
  - ✅ Admin functions
- **Size**: ~3.5 KB / ~130 LOC
- **Status**: Scaffolding complete

---

## 📊 Project Metrics

### Code Statistics
- **Total Contracts**: 3 (2 main + 1 interface)
- **Total Lines of Code**: ~820 LOC
- **Test Files**: 2
- **Test Coverage**: ~27% (needs completion)

### File Count by Type
- Solidity files: 3
- TypeScript files: 3 (2 tests + 1 config)
- Markdown files: 8
- Config files: 4

### Documentation Coverage
- ✅ Project README
- ✅ Technical scope
- ✅ Development roadmap
- ✅ Frontend design specs
- ✅ Task tracking
- ✅ Technical notes
- ✅ File structure

---

## 🔗 File Dependencies

### Dependency Graph

```
hardhat.config.ts
    ├── contracts/MirrorGovernor.sol
    │   └── (depends on Layer-0 SDK - TODO)
    │
    ├── contracts/MainnetExecutor.sol
    │   ├── contracts/interfaces/ICompoundBravoLike.sol
    │   └── (depends on Layer-0 SDK - TODO)
    │
    └── test/*.test.ts
        └── @nomicfoundation/hardhat-ethers

package.json
    ├── hardhat
    ├── @openzeppelin/contracts-upgradeable
    ├── @layerzerolabs/* (to be added)
    └── testing libraries

.env
    └── hardhat.config.ts (RPC URLs, API keys)
```

### Import Map

**MirrorGovernor.sol imports**:
```solidity
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
// TODO: import "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/OApp.sol";
```

**MainnetExecutor.sol imports**:
```solidity
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./interfaces/ICompoundBravoLike.sol";
// TODO: import "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/OApp.sol";
```

---

## 🚀 Deployment Artifacts (Future)

### To be added after deployment:

```
├── 📂 deployments/
│   ├── 📂 base-mainnet/
│   │   ├── MirrorGovernor.json
│   │   └── addresses.json
│   │
│   ├── 📂 ethereum-mainnet/
│   │   ├── MainnetExecutor.json
│   │   └── addresses.json
│   │
│   ├── 📂 base-sepolia/
│   │   └── (testnet deployments)
│   │
│   └── 📂 ethereum-sepolia/
│       └── (testnet deployments)
│
├── 📂 abi/
│   ├── MirrorGovernor.json
│   ├── MainnetExecutor.json
│   └── ICompoundBravoLike.json
│
└── 📂 typechain-types/
    └── (auto-generated TypeScript types)
```

---

## 📝 Next Files to Add

### High Priority
1. **scripts/deploy-mirror-governor.ts** - Base deployment script
2. **scripts/deploy-mainnet-executor.ts** - Ethereum deployment script
3. **scripts/configure-layer0.ts** - Layer-0 endpoint setup
4. **.openzeppelin/base.json** - Proxy deployment tracking
5. **.openzeppelin/mainnet.json** - Proxy deployment tracking

### Medium Priority
6. **scripts/verify-contracts.ts** - Etherscan verification
7. **scripts/delegate-voting-power.ts** - Delegate to executor
8. **docs/deployment-guide.md** - Step-by-step deployment
9. **docs/emergency-procedures.md** - Emergency response plan
10. **LICENSE** - MIT license file

### Low Priority (Phase 3)
11. **frontend/** - Next.js application (Phase 3)
12. **docs/api.md** - API documentation
13. **docs/architecture.md** - Detailed architecture diagrams
14. **.github/workflows/** - CI/CD pipelines

---

## 🔄 File Change Log

### 2025-10-08 (Initial Setup)
- ✅ Created repository structure
- ✅ Added all core documentation
- ✅ Implemented contract skeletons
- ✅ Set up test scaffolding
- ✅ Configured Hardhat for multi-chain

### Pending Changes
- 🔴 Install Layer-0 v2 dependencies
- 🔴 Complete contract implementations
- 🔴 Add deployment scripts
- 🔴 Write comprehensive tests
- 🔴 Set up CI/CD pipeline

---

**Project**: NDA ↔ Lil Nouns Governance Bridge
**Phase**: 1 - Foundation & Core Contracts
**File Count**: 19 files (9 committed)
**Total Size**: ~70 KB
