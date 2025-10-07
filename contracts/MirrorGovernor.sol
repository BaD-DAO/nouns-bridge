// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/**
 * @title MirrorGovernor
 * @notice Mirrors Lil Nouns proposals on Base L2 and manages NDA token holder voting
 * @dev Implements Layer-0 OApp sender to communicate results to Mainnet Executor
 *
 * Key Features:
 * - Mirror Lil Nouns proposals with Compound Bravo semantics
 * - Manage NDA token holder votes (ERC-721/ERC-20 support)
 * - Finalize results and send to Mainnet via Layer-0
 * - Configurable quorum and voting parameters
 * - Pausable and upgradeable (UUPS pattern)
 */
contract MirrorGovernor is
    Initializable,
    OwnableUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable
{
    /*//////////////////////////////////////////////////////////////
                                 TYPES
    //////////////////////////////////////////////////////////////*/

    /// @notice Possible states for a mirrored proposal
    enum ProposalState {
        Pending,      // Proposal has been mirrored but voting hasn't started
        Active,       // Proposal is currently accepting votes
        Defeated,     // Proposal failed to meet quorum or was voted down
        Succeeded,    // Proposal passed and is ready to be sent to mainnet
        Finalized     // Result has been sent to mainnet via Layer-0
    }

    /// @notice Support types matching Compound Bravo
    enum VoteType {
        Against,  // 0
        For,      // 1
        Abstain   // 2
    }

    /// @notice Mirrored proposal struct
    struct MirroredProposal {
        uint256 id;                  // Lil Nouns proposal ID
        uint256 startBlock;          // Voting start block (Base)
        uint256 endBlock;            // Voting end block (Base)
        uint256 forVotes;            // Total votes in favor
        uint256 againstVotes;        // Total votes against
        uint256 abstainVotes;        // Total abstain votes
        bool finalized;              // Whether result has been finalized
        mapping(address => Receipt) receipts;  // Voter receipts
    }

    /// @notice Ballot receipt for a voter
    struct Receipt {
        bool hasVoted;
        uint8 support;
        uint96 votes;
    }

    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice NDA voting token address (ERC-721 or ERC-20)
    address public votingToken;

    /// @notice Quorum in basis points (e.g., 2000 = 20%)
    uint256 public quorumBps;

    /// @notice Mirrored proposals by Lil Nouns proposal ID
    mapping(uint256 => MirroredProposal) public proposals;

    /// @notice Layer-0 endpoint for cross-chain messaging
    address public lzEndpoint;

    /// @notice Mainnet Executor address (destination)
    address public mainnetExecutor;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event ProposalMirrored(
        uint256 indexed proposalId,
        uint256 startBlock,
        uint256 endBlock
    );

    event VoteCast(
        address indexed voter,
        uint256 indexed proposalId,
        uint8 support,
        uint256 votes,
        string reason
    );

    event ProposalFinalized(
        uint256 indexed proposalId,
        uint8 winningSupprt,
        uint256 forVotes,
        uint256 againstVotes,
        uint256 abstainVotes
    );

    event QuorumUpdated(uint256 oldQuorum, uint256 newQuorum);

    /*//////////////////////////////////////////////////////////////
                             INITIALIZATION
    //////////////////////////////////////////////////////////////*/

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initialize the MirrorGovernor contract
     * @param _votingToken NDA token address
     * @param _quorumBps Initial quorum in basis points
     * @param _lzEndpoint Layer-0 endpoint address
     * @param _mainnetExecutor Mainnet Executor address
     */
    function initialize(
        address _votingToken,
        uint256 _quorumBps,
        address _lzEndpoint,
        address _mainnetExecutor
    ) external initializer {
        __Ownable_init(msg.sender);
        __Pausable_init();
        __UUPSUpgradeable_init();

        votingToken = _votingToken;
        quorumBps = _quorumBps;
        lzEndpoint = _lzEndpoint;
        mainnetExecutor = _mainnetExecutor;
    }

    /*//////////////////////////////////////////////////////////////
                           PROPOSAL MIRRORING
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Mirror a Lil Nouns proposal to Base
     * @param proposalId Lil Nouns proposal ID
     * @param startBlock Voting start block on Base
     * @param endBlock Voting end block on Base
     */
    function mirrorProposal(
        uint256 proposalId,
        uint256 startBlock,
        uint256 endBlock
    ) external onlyOwner whenNotPaused {
        require(proposals[proposalId].id == 0, "Proposal already mirrored");
        require(endBlock > startBlock, "Invalid block range");

        MirroredProposal storage proposal = proposals[proposalId];
        proposal.id = proposalId;
        proposal.startBlock = startBlock;
        proposal.endBlock = endBlock;

        emit ProposalMirrored(proposalId, startBlock, endBlock);
    }

    /*//////////////////////////////////////////////////////////////
                              VOTING LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Cast a vote on a mirrored proposal
     * @param proposalId The proposal ID
     * @param support Vote type (0=Against, 1=For, 2=Abstain)
     */
    function castVote(uint256 proposalId, uint8 support) external whenNotPaused {
        return _castVote(msg.sender, proposalId, support, "");
    }

    /**
     * @notice Cast a vote with a reason
     * @param proposalId The proposal ID
     * @param support Vote type (0=Against, 1=For, 2=Abstain)
     * @param reason Voting reason
     */
    function castVoteWithReason(
        uint256 proposalId,
        uint8 support,
        string calldata reason
    ) external whenNotPaused {
        return _castVote(msg.sender, proposalId, support, reason);
    }

    /**
     * @notice Internal vote casting logic
     */
    function _castVote(
        address voter,
        uint256 proposalId,
        uint8 support,
        string memory reason
    ) internal {
        require(state(proposalId) == ProposalState.Active, "Voting closed");
        require(support <= uint8(VoteType.Abstain), "Invalid vote type");

        MirroredProposal storage proposal = proposals[proposalId];
        Receipt storage receipt = proposal.receipts[voter];

        require(!receipt.hasVoted, "Already voted");

        uint96 votes = _getVotes(voter);
        require(votes > 0, "No voting power");

        receipt.hasVoted = true;
        receipt.support = support;
        receipt.votes = votes;

        if (support == uint8(VoteType.Against)) {
            proposal.againstVotes += votes;
        } else if (support == uint8(VoteType.For)) {
            proposal.forVotes += votes;
        } else if (support == uint8(VoteType.Abstain)) {
            proposal.abstainVotes += votes;
        }

        emit VoteCast(voter, proposalId, support, votes, reason);
    }

    /*//////////////////////////////////////////////////////////////
                          FINALIZATION LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Finalize proposal and send result to mainnet
     * @param proposalId The proposal ID to finalize
     * @dev TODO: Implement Layer-0 message sending
     */
    function finalizeProposal(uint256 proposalId) external whenNotPaused {
        require(state(proposalId) == ProposalState.Succeeded || state(proposalId) == ProposalState.Defeated, "Cannot finalize");

        MirroredProposal storage proposal = proposals[proposalId];
        require(!proposal.finalized, "Already finalized");

        proposal.finalized = true;

        // Determine winning support
        uint8 winningSupport = _determineOutcome(proposalId);

        emit ProposalFinalized(
            proposalId,
            winningSupport,
            proposal.forVotes,
            proposal.againstVotes,
            proposal.abstainVotes
        );

        // TODO: Send Layer-0 message to mainnet
        // _sendToMainnet(proposalId, winningSupport);
    }

    /*//////////////////////////////////////////////////////////////
                              VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Get the current state of a proposal
     * @param proposalId The proposal ID
     * @return Current proposal state
     */
    function state(uint256 proposalId) public view returns (ProposalState) {
        MirroredProposal storage proposal = proposals[proposalId];

        if (proposal.id == 0) revert("Proposal does not exist");
        if (proposal.finalized) return ProposalState.Finalized;
        if (block.number < proposal.startBlock) return ProposalState.Pending;
        if (block.number <= proposal.endBlock) return ProposalState.Active;

        // Voting has ended, check if succeeded or defeated
        if (_quorumReached(proposalId) && _voteSucceeded(proposalId)) {
            return ProposalState.Succeeded;
        } else {
            return ProposalState.Defeated;
        }
    }

    /**
     * @notice Check if quorum has been reached
     * @param proposalId The proposal ID
     * @return True if quorum reached
     */
    function _quorumReached(uint256 proposalId) internal view returns (bool) {
        MirroredProposal storage proposal = proposals[proposalId];
        uint256 totalVotes = proposal.forVotes + proposal.againstVotes + proposal.abstainVotes;

        // TODO: Get total supply from voting token
        uint256 totalSupply = 1000; // Placeholder
        uint256 quorum = (totalSupply * quorumBps) / 10000;

        return totalVotes >= quorum;
    }

    /**
     * @notice Check if vote has succeeded
     * @param proposalId The proposal ID
     * @return True if vote succeeded
     */
    function _voteSucceeded(uint256 proposalId) internal view returns (bool) {
        MirroredProposal storage proposal = proposals[proposalId];
        return proposal.forVotes > proposal.againstVotes;
    }

    /**
     * @notice Determine the outcome of a vote
     * @param proposalId The proposal ID
     * @return Winning support value (0=Against, 1=For, 2=Abstain if tie)
     */
    function _determineOutcome(uint256 proposalId) internal view returns (uint8) {
        MirroredProposal storage proposal = proposals[proposalId];

        if (proposal.forVotes > proposal.againstVotes) {
            return uint8(VoteType.For);
        } else {
            return uint8(VoteType.Against);
        }
    }

    /**
     * @notice Get voting power for an address
     * @param voter The voter address
     * @return Number of votes
     * @dev TODO: Implement ERC-721 and ERC-20 token balance checks
     */
    function _getVotes(address voter) internal view returns (uint96) {
        // TODO: Query votingToken balance (ERC-721 or ERC-20)
        // For ERC-721: return balanceOf(voter)
        // For ERC-20: return balanceOf(voter) / 1e18 (or configured decimals)
        return 1; // Placeholder
    }

    /*//////////////////////////////////////////////////////////////
                          ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Update quorum basis points
     * @param newQuorumBps New quorum in basis points
     */
    function setQuorum(uint256 newQuorumBps) external onlyOwner {
        require(newQuorumBps <= 10000, "Invalid quorum");
        emit QuorumUpdated(quorumBps, newQuorumBps);
        quorumBps = newQuorumBps;
    }

    /**
     * @notice Pause contract
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Unpause contract
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @notice Authorize upgrade (UUPS)
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
