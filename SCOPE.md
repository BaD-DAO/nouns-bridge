# Project Scope: NDA ↔ Lil Nouns Governance Bridge

## 🎯 Objectives

1. **Mirror Lil Nouns proposals on-chain** to Base in near-real-time
2. **Allow NDA token holders** (ERC-721 or ERC-20) to vote on mirrored proposals on Base
3. **Aggregate and finalize** the Base vote on-chain with quorum/thresholds that mirror Lil Nouns' rules
4. **Cast the corresponding vote on Ethereum** through a mainnet Executor contract that controls pre-delegated voting power
5. **Eliminate off-chain trust** (no Snapshot, no cron bots) while maintaining clear pause/upgrade controls

## 📦 Contract Deliverables

### 1. MirrorGovernor.sol (Base L2)

**Location:** `contracts/MirrorGovernor.sol`

**Purpose:** Mirror Lil Nouns proposals and manage NDA token holder voting on Base

**Key Features:**
- Maintain registry of mirrored proposals keyed by Lil Nouns `proposalId`
- Enforce voting window congruent with Compound Bravo (`startBlock` → `endBlock`)
- Configurable quorum and vote success rules
- Support mapping of votes to Compound support codes (0=Against, 1=For, 2=Abstain)
- Finalize result and emit `Finalized(proposalId, support, tally)` event
- Layer-0 OApp sender: pack result and send to Mainnet Executor

**Safety Features:**
- Pausable mirroring and voting
- Upgradeable via UUPS/Transparent Proxy
- Replay protection and proposalId binding
- Access control for proposal mirroring

**Standards:**
- Custom voting contract leveraging OpenZeppelin modules
- Must mirror Compound Bravo semantics
- ERC-721/ERC-20 voting token support

### 2. MainnetExecutor.sol (Ethereum L1)

**Location:** `contracts/MainnetExecutor.sol`

**Purpose:** Receive finalized votes from Base and cast them on Lil Nouns Governor

**Key Features:**
- Layer-0 OApp receiver: validates message origin (Base MirrorGovernor + endpoint)
- Calls `castVoteWithReason(proposalId, support, reason)` on Lil Nouns Governor
- Idempotency check using `getReceipt` to prevent double-votes
- Must hold delegated Lil Nouns voting power before proposal `startBlock`

**Safety Features:**
- Only accept messages from authorized Base app/endpoint
- Pausable with emergency delegation controls
- Message replay protection
- Access control for critical operations

**Requirements:**
- Must be delegatee of Lil Nouns voting tokens before each proposal's `startBlock`
- Implements ICompoundBravoLike interface for Lil Nouns Governor interaction

### 3. ICompoundBravoLike.sol (Interface)

**Location:** `contracts/interfaces/ICompoundBravoLike.sol`

**Purpose:** Interface for Lil Nouns Governor (Compound Bravo fork)

**Key Functions:**
```solidity
function castVote(uint256 proposalId, uint8 support) external;
function castVoteWithReason(uint256 proposalId, uint8 support, string calldata reason) external;
function proposals(uint256 proposalId) external view returns (...);
function getActions(uint256 proposalId) external view returns (...);
function getReceipt(uint256 proposalId, address voter) external view returns (...);
```

## ⚙️ Governance Parameters (Configurable)

### Voting Token
- **Type:** ERC-721 or ERC-20
- **Address:** NDA token contract on Base
- **Voting Power:** Balance-based (1 token = 1 vote for ERC-721, proportional for ERC-20)

### Support Mapping
- **For:** Maps to Compound's `1`
- **Against:** Maps to Compound's `0`
- **Abstain:** Maps to Compound's `2` (if enabled)

### Quorum & Thresholds
- **Quorum BPS:** Configurable basis points (default: 2000 = 20%)
- **Success Rule:** Majority (For > Against) or stricter
- **Quorum Source:** Can mirror Lil Nouns' quorum semantics

### Voting Windows
- **Alignment:** Match Compound's `startBlock`/`endBlock`
- **Block Mapping:** Base blocks mapped to Ethereum blocks
- **Snapshot:** Voting power snapshot at proposal creation

## 🔐 Security & Trust Model

### Cross-Chain Security
- **Messaging Layer:** LayerZero v2 OApp
- **Verification:** Multi-DVN (Decentralized Verifier Network)
- **Alternative:** Hyperlane ISM (if needed)

### Replay Protection
- Store mirrored proposal root
- Bind messages to specific proposalId
- Nonce-based message ordering

### Pausing & Upgrades
- Proxy-based upgrades (UUPS pattern)
- DAO multisig control
- Emergency pause functionality
- Timelocked parameter changes

### Delegation Operations
- Ensure voting power delegated before each proposal's `startBlock`
- Monitor delegation status
- Emergency delegation recovery

## 🧪 Testing Requirements

### Unit Tests
- Vote tallying accuracy
- Quorum threshold checks
- Compound support code mapping
- Access control verification
- Edge cases (ties, low participation)

### Integration Tests
- Full flow: Mirror → Vote → Finalize → Message → Cast
- Layer-0 message verification
- Cross-chain communication
- Proposal state transitions

### Fork Tests
- Validate against Lil Nouns Governor on mainnet fork
- Test with real proposal data
- Verify delegation mechanics
- Test emergency scenarios

### Gas Optimization
- Batch operations where possible
- Optimize storage patterns
- Minimize cross-chain message size

## 🔄 Migration from Old Scope

### Key Changes
- Replace OZ Governor references with Compound Bravo-like interface
- Map Base tallies into Compound enums
- Mirror `startBlock` and `endBlock` accurately
- Use `getReceipt` to prevent duplicate votes
- Implement Layer-0 v2 OApp pattern

### Backward Compatibility
- Maintain existing NDA token contracts
- No changes to Lil Nouns Governor required
- Support gradual migration from Snapshot

## 🖥️ Frontend Requirements (Phase 3)

### Proposal List Page
- Display mirrored proposals from MirrorGovernor events
- Show Compound proposal data (title, description, status)
- Real-time vote counts from Base
- Mainnet vote status (has voted, support)

### Voting Interface
- Cast votes on Base (For/Against/Abstain)
- Display voting power
- Show proposal timeline
- Transaction status and confirmations

### Results Dashboard
- Mirrored vote tallies from Base
- Mainnet vote receipt status
- Cross-chain message status
- Historical voting records

### Wallet Integration
- MetaMask, WalletConnect support
- Network switching (Base ↔ Ethereum)
- Transaction signing
- Event notifications

## 📊 Key Metrics & Monitoring

### On-Chain Metrics
- Proposals mirrored
- Votes cast on Base
- Successful mainnet executions
- Failed messages (requires investigation)

### Operational Metrics
- Layer-0 message delivery time
- Gas costs (Base + Mainnet)
- Delegation status
- Quorum participation rates

## 🚫 Out of Scope (Phase 1)

- Proposal creation from Base (mirror only)
- Multi-chain aggregation beyond Base
- Off-chain Snapshot integration
- Automated proposal mirroring (manual trigger acceptable)
- Frontend implementation (design documentation only)

## 📝 Success Criteria

1. ✅ Successfully mirror Lil Nouns proposals to Base
2. ✅ NDA holders can vote on Base with their tokens
3. ✅ Votes finalize correctly with proper quorum checks
4. ✅ Layer-0 messages deliver reliably (>99% success rate)
5. ✅ Mainnet Executor casts votes on Lil Nouns Governor
6. ✅ No double-voting possible
7. ✅ All contracts audited and deployed
8. ✅ Comprehensive test coverage (>90%)
9. ✅ Documentation complete (contracts + UI/UX design)

## 🔗 External Dependencies

- Layer-0 v2 infrastructure (endpoints, DVNs)
- Base L2 network
- Ethereum Mainnet
- Lil Nouns Governor contract (existing)
- NDA token contract (existing)
- RPC providers (Alchemy, Infura)
- IPFS for proposal metadata (optional)

---

**Document Version:** 1.0
**Last Updated:** 2025-10-08
**Status:** Phase 1 Specification
