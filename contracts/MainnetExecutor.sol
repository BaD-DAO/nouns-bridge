// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./interfaces/ICompoundBravoLike.sol";

/**
 * @title MainnetExecutor
 * @notice Receives finalized votes from Base and casts them on Lil Nouns Governor
 * @dev Implements Layer-0 OApp receiver for cross-chain vote execution
 *
 * Key Features:
 * - Receives verified Layer-0 messages from Base MirrorGovernor
 * - Casts votes on Lil Nouns Governor (Compound Bravo fork)
 * - Prevents double-voting via idempotency checks
 * - Must hold delegated Lil Nouns voting power
 * - Pausable and upgradeable (UUPS pattern)
 *
 * CRITICAL: This contract must be delegated Lil Nouns voting power BEFORE
 * each proposal's snapshot block, or votes will not count.
 */
contract MainnetExecutor is
    Initializable,
    OwnableUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable
{
    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice Lil Nouns Governor contract (Compound Bravo fork)
    ICompoundBravoLike public lilNounsGovernor;

    /// @notice Layer-0 endpoint for receiving messages
    address public lzEndpoint;

    /// @notice Base MirrorGovernor address (authorized sender)
    address public baseMirrorGovernor;

    /// @notice Base chain ID for Layer-0
    uint16 public baseChainId;

    /// @notice Track executed proposals to prevent replay
    mapping(uint256 => bool) public executedProposals;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event VoteExecuted(
        uint256 indexed proposalId,
        uint8 support,
        uint256 votes,
        string reason
    );

    event GovernorUpdated(address indexed oldGovernor, address indexed newGovernor);
    event BaseMirrorGovernorUpdated(address indexed oldMirror, address indexed newMirror);

    /*//////////////////////////////////////////////////////////////
                             INITIALIZATION
    //////////////////////////////////////////////////////////////*/

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initialize the MainnetExecutor contract
     * @param _lilNounsGovernor Lil Nouns Governor address
     * @param _lzEndpoint Layer-0 endpoint address
     * @param _baseMirrorGovernor Base MirrorGovernor address
     * @param _baseChainId Base chain ID for Layer-0
     */
    function initialize(
        address _lilNounsGovernor,
        address _lzEndpoint,
        address _baseMirrorGovernor,
        uint16 _baseChainId
    ) external initializer {
        __Ownable_init(msg.sender);
        __Pausable_init();
        __UUPSUpgradeable_init();

        lilNounsGovernor = ICompoundBravoLike(_lilNounsGovernor);
        lzEndpoint = _lzEndpoint;
        baseMirrorGovernor = _baseMirrorGovernor;
        baseChainId = _baseChainId;
    }

    /*//////////////////////////////////////////////////////////////
                          LAYER-0 MESSAGE HANDLING
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Receive and process Layer-0 message from Base
     * @param _srcChainId Source chain ID
     * @param _srcAddress Source contract address
     * @param _payload Encoded vote data (proposalId, support, reason)
     * @dev TODO: Implement full Layer-0 lzReceive interface
     */
    function receiveVote(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        bytes memory _payload
    ) external whenNotPaused {
        // TODO: Add Layer-0 endpoint validation
        // require(msg.sender == lzEndpoint, "Only endpoint");
        require(_srcChainId == baseChainId, "Invalid source chain");

        // TODO: Validate source address matches baseMirrorGovernor
        // address srcAddr = _bytesToAddress(_srcAddress);
        // require(srcAddr == baseMirrorGovernor, "Invalid source");

        // Decode payload
        (uint256 proposalId, uint8 support, string memory reason) = abi.decode(
            _payload,
            (uint256, uint8, string)
        );

        _executeVote(proposalId, support, reason);
    }

    /*//////////////////////////////////////////////////////////////
                          VOTE EXECUTION LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Execute vote on Lil Nouns Governor
     * @param proposalId Proposal ID from Lil Nouns
     * @param support Vote type (0=Against, 1=For, 2=Abstain)
     * @param reason Voting reason from Base finalization
     */
    function _executeVote(
        uint256 proposalId,
        uint8 support,
        string memory reason
    ) internal {
        // Check if already executed (prevent replay/double-vote)
        require(!executedProposals[proposalId], "Already executed");

        // Check if we've already voted (idempotency check)
        (bool hasVoted, , uint96 votes) = lilNounsGovernor.getReceipt(
            proposalId,
            address(this)
        );

        require(!hasVoted, "Already voted on this proposal");
        require(votes > 0 || _checkDelegation(), "No voting power");

        // Mark as executed before external call (CEI pattern)
        executedProposals[proposalId] = true;

        // Cast vote on Lil Nouns Governor
        if (bytes(reason).length > 0) {
            lilNounsGovernor.castVoteWithReason(proposalId, support, reason);
        } else {
            lilNounsGovernor.castVote(proposalId, support);
        }

        emit VoteExecuted(proposalId, support, votes, reason);
    }

    /**
     * @notice Manual vote execution (emergency/fallback)
     * @param proposalId Proposal ID
     * @param support Vote type
     * @param reason Voting reason
     * @dev Only owner can call in case Layer-0 message fails
     */
    function executeVoteManual(
        uint256 proposalId,
        uint8 support,
        string calldata reason
    ) external onlyOwner whenNotPaused {
        _executeVote(proposalId, support, reason);
    }

    /*//////////////////////////////////////////////////////////////
                              VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Check if this contract has voting power delegation
     * @return True if delegated voting power exists
     * @dev TODO: Implement proper delegation check with Lil Nouns token
     */
    function _checkDelegation() internal view returns (bool) {
        // TODO: Query Lil Nouns token for delegation to this address
        // Example: return lilNounsToken.delegates(someAddress) == address(this);
        return true; // Placeholder
    }

    /**
     * @notice Get current voting power
     * @return Current voting power of this contract
     */
    function getVotingPower() external view returns (uint96) {
        // TODO: Query Lil Nouns token for current voting power
        // This will depend on delegation and token balance
        return 0; // Placeholder
    }

    /**
     * @notice Check if proposal has been executed
     * @param proposalId Proposal ID
     * @return True if executed
     */
    function isExecuted(uint256 proposalId) external view returns (bool) {
        return executedProposals[proposalId];
    }

    /**
     * @notice Get voting receipt from Lil Nouns Governor
     * @param proposalId Proposal ID
     * @return hasVoted Whether vote was cast
     * @return support Vote type
     * @return votes Number of votes
     */
    function getReceipt(uint256 proposalId)
        external
        view
        returns (
            bool hasVoted,
            uint8 support,
            uint96 votes
        )
    {
        return lilNounsGovernor.getReceipt(proposalId, address(this));
    }

    /**
     * @notice Get proposal details from Lil Nouns Governor
     * @param proposalId Proposal ID
     * @return Proposal struct from Lil Nouns Governor
     */
    function getProposal(uint256 proposalId)
        external
        view
        returns (
            uint256 id,
            address proposer,
            uint256 eta,
            uint256 startBlock,
            uint256 endBlock,
            uint256 forVotes,
            uint256 againstVotes,
            uint256 abstainVotes,
            bool canceled,
            bool executed
        )
    {
        return lilNounsGovernor.proposals(proposalId);
    }

    /*//////////////////////////////////////////////////////////////
                          ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Update Lil Nouns Governor address
     * @param newGovernor New governor address
     */
    function setGovernor(address newGovernor) external onlyOwner {
        require(newGovernor != address(0), "Invalid address");
        emit GovernorUpdated(address(lilNounsGovernor), newGovernor);
        lilNounsGovernor = ICompoundBravoLike(newGovernor);
    }

    /**
     * @notice Update Base MirrorGovernor address
     * @param newMirrorGovernor New mirror governor address
     */
    function setBaseMirrorGovernor(address newMirrorGovernor) external onlyOwner {
        require(newMirrorGovernor != address(0), "Invalid address");
        emit BaseMirrorGovernorUpdated(baseMirrorGovernor, newMirrorGovernor);
        baseMirrorGovernor = newMirrorGovernor;
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

    /*//////////////////////////////////////////////////////////////
                            HELPER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Convert bytes to address
     * @param _bytes Bytes to convert
     * @return addr Address
     */
    function _bytesToAddress(bytes memory _bytes) internal pure returns (address addr) {
        require(_bytes.length >= 20, "Invalid bytes length");
        assembly {
            addr := mload(add(_bytes, 20))
        }
    }
}
