# Development Notes: NounsBridge

## 📋 Technical Specifications

**Last Updated**: 2025-10-08

---

## System Architecture

### High-Level Flow

```
Ethereum Mainnet (L1)                    Base L2
┌─────────────────────┐                 ┌─────────────────────┐
│  Lil Nouns Governor │                 │   NDA Token         │
│  (Compound Bravo)   │                 │   (ERC-721/ERC-20)  │
└──────────┬──────────┘                 └──────────┬──────────┘
           │                                       │
           │ Proposal Created                      │ Voting Power
           │                                       │
┌──────────▼──────────┐    Layer-0     ┌──────────▼──────────┐
│  MainnetExecutor    │◄───────────────►│  MirrorGovernor     │
│  - Receives votes   │    Messages     │  - Mirrors proposals│
│  - Casts on Governor│                 │  - Manages voting   │
└─────────────────────┘                 │  - Finalizes results│
                                        └─────────────────────┘
```

### Message Flow

1. **Proposal Mirroring** (Off-chain or minimal on-chain trigger)
   - Lil Nouns proposal created on Ethereum
   - Mirror proposal to Base MirrorGovernor
   - Include: proposalId, startBlock, endBlock, description

2. **Voting on Base**
   - NDA holders vote during active period
   - Votes tallied on-chain
   - Quorum checked continuously

3. **Finalization on Base**
   - Voting period ends
   - Check quorum and vote outcome
   - Lock result, emit Finalized event
   - Pack Layer-0 message: (proposalId, support, reason)

4. **Cross-Chain Execution**
   - Layer-0 sends message to Ethereum
   - MainnetExecutor receives and validates
   - Check idempotency (not already voted)
   - Cast vote on Lil Nouns Governor

---

## Smart Contract Details

### MirrorGovernor.sol (Base)

**Purpose**: Mirror Lil Nouns proposals and manage NDA token holder voting

**Key State Variables**:
```solidity
address public votingToken;           // NDA token (ERC-721 or ERC-20)
uint256 public quorumBps;            // Quorum in basis points (e.g., 2000 = 20%)
address public lzEndpoint;           // Layer-0 endpoint
address public mainnetExecutor;      // Mainnet executor address

mapping(uint256 => MirroredProposal) public proposals;
```

**MirroredProposal Struct**:
```solidity
struct MirroredProposal {
    uint256 id;                  // Lil Nouns proposal ID
    uint256 startBlock;          // Voting start (Base block)
    uint256 endBlock;            // Voting end (Base block)
    uint256 forVotes;            // Total For votes
    uint256 againstVotes;        // Total Against votes
    uint256 abstainVotes;        // Total Abstain votes
    bool finalized;              // Finalized flag
    mapping(address => Receipt) receipts;
}
```

**Vote Types** (Compound Bravo standard):
- `0` = Against
- `1` = For
- `2` = Abstain

**Key Functions**:
- `mirrorProposal(uint256 proposalId, uint256 startBlock, uint256 endBlock)` - Owner only
- `castVote(uint256 proposalId, uint8 support)` - Public
- `castVoteWithReason(uint256 proposalId, uint8 support, string reason)` - Public
- `finalizeProposal(uint256 proposalId)` - Public (after voting ends)
- `state(uint256 proposalId)` - View (returns ProposalState)

**Proposal States**:
```solidity
enum ProposalState {
    Pending,      // Mirrored but not started
    Active,       // Currently voting
    Defeated,     // Failed quorum or vote
    Succeeded,    // Passed vote
    Finalized     // Sent to mainnet
}
```

**TODOs**:
- [ ] Implement Layer-0 `_lzSend` for cross-chain messaging
- [ ] Add voting power calculation for ERC-721/ERC-20
- [ ] Implement proper total supply queries
- [ ] Add proposal metadata (IPFS hash)

---

### MainnetExecutor.sol (Ethereum)

**Purpose**: Receive finalized votes from Base and execute on Lil Nouns Governor

**Key State Variables**:
```solidity
ICompoundBravoLike public lilNounsGovernor;
address public lzEndpoint;
address public baseMirrorGovernor;
uint16 public baseChainId;

mapping(uint256 => bool) public executedProposals;
```

**Key Functions**:
- `receiveVote(uint16 srcChainId, bytes srcAddress, bytes payload)` - Internal (Layer-0)
- `executeVoteManual(uint256 proposalId, uint8 support, string reason)` - Owner only (fallback)
- `getReceipt(uint256 proposalId)` - View (from Lil Nouns Governor)
- `isExecuted(uint256 proposalId)` - View

**Security Checks**:
1. Validate source chain ID matches Base
2. Validate source address matches baseMirrorGovernor
3. Check proposal not already executed (replay protection)
4. Check not already voted via `getReceipt`
5. Verify voting power delegation (external check)

**TODOs**:
- [ ] Implement Layer-0 `_lzReceive` function
- [ ] Add delegation validation logic
- [ ] Implement emergency vote execution
- [ ] Add multi-sig controls for critical functions

---

### ICompoundBravoLike.sol

**Purpose**: Interface for Lil Nouns Governor (Compound Bravo fork)

**Key Functions**:
```solidity
function castVote(uint256 proposalId, uint8 support) external;
function castVoteWithReason(uint256 proposalId, uint8 support, string calldata reason) external;
function proposals(uint256 proposalId) external view returns (...);
function getActions(uint256 proposalId) external view returns (...);
function getReceipt(uint256 proposalId, address voter) external view returns (...);
```

**Receipt Struct**:
```solidity
struct Receipt {
    bool hasVoted;
    uint8 support;
    uint96 votes;
}
```

---

## Layer-0 Integration

### OApp Pattern

**Base MirrorGovernor** (Sender):
```solidity
import "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/OApp.sol";

// In finalization:
bytes memory payload = abi.encode(proposalId, support, reason);
_lzSend(
    dstEid,              // Mainnet endpoint ID
    payload,             // Encoded message
    options,             // Gas options
    MessagingFee(msg.value, 0),
    payable(msg.sender)
);
```

**Mainnet Executor** (Receiver):
```solidity
function _lzReceive(
    Origin calldata _origin,
    bytes32 _guid,
    bytes calldata _message,
    address _executor,
    bytes calldata _extraData
) internal override {
    // Validate origin
    require(_origin.srcEid == baseSrcEid, "Invalid source");

    // Decode and execute
    (uint256 proposalId, uint8 support, string memory reason) = abi.decode(_message, (uint256, uint8, string));
    _executeVote(proposalId, support, reason);
}
```

### DVN Configuration

**Multi-DVN Setup** (for security):
```javascript
const dvnConfig = {
  requiredDVNs: [
    "0x...", // LayerZero DVN
    "0x...", // Google Cloud DVN
    "0x...", // Polyhedra DVN
  ],
  requiredDVNCount: 2,  // 2-of-3 verification
  optionalDVNThreshold: 0
};
```

### Gas Estimation

**Base → Mainnet Message**:
- Base gas: ~50,000 (proposal finalization)
- Layer-0 gas: ~200,000 (cross-chain message)
- Mainnet gas: ~100,000 (castVoteWithReason)
- **Total**: ~350,000 gas units

**Cost Estimate** (at 30 gwei):
- Mainnet: ~0.01 ETH
- Base: ~0.001 ETH (cheaper L2 gas)

---

## Configuration Parameters

### MirrorGovernor

```javascript
{
  votingToken: "0x...",          // NDA token on Base
  quorumBps: 2000,              // 20% quorum
  lzEndpoint: "0x...",          // Base Layer-0 endpoint
  mainnetExecutor: "0x...",     // Mainnet executor address
}
```

### MainnetExecutor

```javascript
{
  lilNounsGovernor: "0x5d2C31ce16924C2a71D317e5BbFd5ce387854039",  // Lil Nouns on Ethereum
  lzEndpoint: "0x...",          // Mainnet Layer-0 endpoint
  baseMirrorGovernor: "0x...",  // Base MirrorGovernor address
  baseChainId: 8453,            // Base mainnet
}
```

### Network Endpoints

**Layer-0 Endpoints**:
- Ethereum Mainnet: `0x1a44076050125825900e736c501f859c50fE728c`
- Base Mainnet: `0x1a44076050125825900e736c501f859c50fE728c`
- Ethereum Sepolia: `0x6EDCE65403992e310A62460808c4b910D972f10f`
- Base Sepolia: `0x6EDCE65403992e310A62460808c4b910D972f10f`

**RPC URLs**:
- Base Mainnet: `https://mainnet.base.org`
- Base Sepolia: `https://sepolia.base.org`
- Ethereum Mainnet: `https://eth-mainnet.g.alchemy.com/v2/{key}`
- Ethereum Sepolia: `https://eth-sepolia.g.alchemy.com/v2/{key}`

---

## Testing Strategy

### Unit Tests

**MirrorGovernor**:
- ✅ Initialization
- ✅ Proposal mirroring (owner only, prevent duplicates)
- ❌ Voting (needs voting power mock)
- ❌ Quorum calculation
- ❌ Finalization and state transitions

**MainnetExecutor**:
- ✅ Initialization
- ✅ Admin functions (setGovernor, pause/unpause)
- ❌ Vote execution (needs Governor mock)
- ❌ Idempotency (prevent double-voting)
- ❌ Layer-0 message handling

### Integration Tests

**Full Flow**:
1. Mirror proposal on Base
2. Cast votes from multiple addresses
3. Reach quorum
4. Finalize and send Layer-0 message
5. Verify message received on Mainnet
6. Verify vote cast on Lil Nouns Governor

### Fork Tests

**Against Lil Nouns Governor**:
```bash
npx hardhat test --fork https://eth-mainnet.g.alchemy.com/v2/{key}
```

Tests:
- Deploy MainnetExecutor on fork
- Delegate Lil Nouns voting power to executor
- Simulate Base finalization message
- Execute vote on actual Lil Nouns Governor
- Verify receipt and vote count

---

## Deployment Checklist

### Pre-Deployment

- [ ] Complete all smart contracts
- [ ] Achieve >90% test coverage
- [ ] Run security analysis (Slither, Mythril)
- [ ] External audit completed
- [ ] Address all audit findings
- [ ] Test on testnets (Base Sepolia, Eth Sepolia)

### Testnet Deployment

**Base Sepolia**:
1. Deploy MirrorGovernor implementation
2. Deploy UUPS proxy
3. Initialize with test parameters
4. Configure Layer-0 endpoint
5. Verify on Basescan

**Ethereum Sepolia**:
1. Deploy MainnetExecutor implementation
2. Deploy UUPS proxy
3. Initialize with test Lil Nouns Governor
4. Configure Layer-0 endpoint
5. Verify on Etherscan

### Mainnet Deployment

**Preparation**:
- [ ] Prepare deployment scripts
- [ ] Set up multisig for ownership
- [ ] Prepare delegation transaction
- [ ] Set up monitoring & alerts
- [ ] Prepare emergency procedures

**Base Mainnet**:
1. Deploy via multisig
2. Initialize with production params
3. Verify contract
4. Set Layer-0 configuration
5. Transfer ownership to DAO multisig

**Ethereum Mainnet**:
1. Deploy via multisig
2. Initialize with Lil Nouns Governor address
3. **CRITICAL**: Delegate Lil Nouns voting power BEFORE proposals
4. Verify contract
5. Set Layer-0 configuration
6. Transfer ownership to DAO multisig

---

## Security Considerations

### Attack Vectors

1. **Replay Attacks**:
   - Mitigation: `executedProposals` mapping
   - Check: `getReceipt` idempotency

2. **Message Spoofing**:
   - Mitigation: Layer-0 DVN verification
   - Validation: Source chain and address checks

3. **Governance Takeover**:
   - Mitigation: Pausable contracts
   - Emergency: Multisig controls

4. **Front-Running**:
   - Risk: Minimal (votes are transparent)
   - Note: Cannot prevent but doesn't affect outcome

### Critical Operations

**Owner Functions** (Multisig only):
- `mirrorProposal()` - Add new proposals
- `setQuorum()` - Update quorum
- `setGovernor()` - Update Lil Nouns Governor address
- `pause()` / `unpause()` - Emergency controls
- `upgradeToAndCall()` - Contract upgrades

**Delegation Management**:
- MainnetExecutor must be delegated Lil Nouns voting power
- Delegation MUST occur before proposal snapshot block
- Monitor delegation status continuously
- Have backup delegation process

---

## Performance Metrics

### Gas Usage (Estimates)

**MirrorGovernor**:
- `mirrorProposal`: ~100,000 gas
- `castVote`: ~80,000 gas
- `finalizeProposal`: ~150,000 gas + Layer-0 fees

**MainnetExecutor**:
- `receiveVote` + `castVoteWithReason`: ~150,000 gas

### Transaction Times

**Base L2**:
- Block time: ~2 seconds
- Finality: ~1-2 minutes (soft)

**Ethereum L1**:
- Block time: ~12 seconds
- Finality: ~15 minutes (2 epochs)

**Layer-0 Message**:
- Delivery time: ~2-5 minutes
- Depends on DVN verification speed

---

## Known Limitations & Future Work

### Current Limitations

1. **Voting Power Calculation**: Placeholder implementation
   - Need to query actual NDA token balances
   - Support both ERC-721 (1 token = 1 vote) and ERC-20 (balance-based)

2. **Layer-0 Integration**: Not fully implemented
   - Need to install Layer-0 v2 packages
   - Complete OApp sender/receiver logic
   - Configure DVNs for production

3. **Delegation Validation**: Basic checks only
   - Need to verify MainnetExecutor has voting power
   - Check delegation occurred before snapshot

4. **Proposal Metadata**: Not stored on-chain
   - Consider IPFS for descriptions
   - Or emit events with metadata

### Future Enhancements

- [ ] Automated proposal mirroring (via keeper network)
- [ ] Batch operations for gas efficiency
- [ ] Governance parameter updates via DAO vote
- [ ] Alternative messaging layers (Hyperlane, Wormhole)
- [ ] Proposal creation from Base (if governance allows)
- [ ] Advanced analytics and participation metrics

---

## Useful Commands

```bash
# Development
npm install
npx hardhat compile
npx hardhat test
npx hardhat coverage

# Gas reporting
REPORT_GAS=true npx hardhat test

# Network-specific testing
npx hardhat test --network hardhat
npx hardhat test --network baseSepolia

# Deployment
npx hardhat run scripts/deploy-mirror-governor.ts --network baseSepolia
npx hardhat run scripts/deploy-mainnet-executor.ts --network sepolia

# Verification
npx hardhat verify --network baseSepolia <address> <constructor-args>

# Upgrade contracts (UUPS)
npx hardhat run scripts/upgrade-mirror-governor.ts --network base

# Fork testing
npx hardhat test --fork https://eth-mainnet.g.alchemy.com/v2/${ALCHEMY_KEY}
```

---

## References

- [Lil Nouns DAO](https://lilnouns.wtf)
- [Compound Governor Bravo](https://github.com/compound-finance/compound-protocol/tree/master/contracts/Governance)
- [Layer-0 v2 Documentation](https://docs.layerzero.network/v2)
- [OpenZeppelin Upgradeable](https://docs.openzeppelin.com/contracts/4.x/upgradeable)
- [Base Documentation](https://docs.base.org)

---

**Project**: NDA ↔ Lil Nouns Governance Bridge
**Phase**: 1 - Foundation & Core Contracts
**Status**: Development In Progress
