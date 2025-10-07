// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ICompoundBravoLike
 * @notice Interface for Lil Nouns Governor (Compound Bravo fork)
 * @dev This interface defines the essential functions needed to interact with
 *      a Compound Governor Bravo-style governance contract.
 */
interface ICompoundBravoLike {
    /// @notice Ballot receipt record for a voter
    struct Receipt {
        bool hasVoted;
        uint8 support;
        uint96 votes;
    }

    /// @notice Proposal struct
    struct Proposal {
        uint256 id;
        address proposer;
        uint256 eta;
        uint256 startBlock;
        uint256 endBlock;
        uint256 forVotes;
        uint256 againstVotes;
        uint256 abstainVotes;
        bool canceled;
        bool executed;
    }

    /**
     * @notice Cast a vote for a proposal
     * @param proposalId The id of the proposal to vote on
     * @param support The support value for the vote. 0=against, 1=for, 2=abstain
     */
    function castVote(uint256 proposalId, uint8 support) external;

    /**
     * @notice Cast a vote for a proposal with a reason
     * @param proposalId The id of the proposal to vote on
     * @param support The support value for the vote. 0=against, 1=for, 2=abstain
     * @param reason The reason given for the vote by the voter
     */
    function castVoteWithReason(
        uint256 proposalId,
        uint8 support,
        string calldata reason
    ) external;

    /**
     * @notice Gets the proposal details
     * @param proposalId The id of the proposal
     * @return id The proposal id
     * @return proposer The address of the proposer
     * @return eta The timestamp that the proposal will be available for execution, set once the vote succeeds
     * @return startBlock The block at which voting begins
     * @return endBlock The block at which voting ends
     * @return forVotes Current number of votes in favor of this proposal
     * @return againstVotes Current number of votes in opposition to this proposal
     * @return abstainVotes Current number of votes for abstaining for this proposal
     * @return canceled Flag marking whether the proposal has been canceled
     * @return executed Flag marking whether the proposal has been executed
     */
    function proposals(uint256 proposalId)
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
        );

    /**
     * @notice Gets actions of a proposal
     * @param proposalId The id of the proposal
     * @return targets The ordered list of target addresses for calls to be made
     * @return values The ordered list of values (i.e. msg.value) to be passed to the calls to be made
     * @return signatures The ordered list of function signatures to be called
     * @return calldatas The ordered list of calldata to be passed to each call
     */
    function getActions(uint256 proposalId)
        external
        view
        returns (
            address[] memory targets,
            uint256[] memory values,
            string[] memory signatures,
            bytes[] memory calldatas
        );

    /**
     * @notice Gets the receipt for a voter on a given proposal
     * @param proposalId The id of proposal
     * @param voter The address of the voter
     * @return hasVoted Whether or not a vote has been cast
     * @return support Which way the vote was cast (0=against, 1=for, 2=abstain)
     * @return votes The number of votes cast
     */
    function getReceipt(uint256 proposalId, address voter)
        external
        view
        returns (
            bool hasVoted,
            uint8 support,
            uint96 votes
        );

    /**
     * @notice The number of votes required in order for a voter to become a proposer
     */
    function proposalThreshold() external view returns (uint256);

    /**
     * @notice The number of votes in support of a proposal required in order for a quorum to be reached and for a vote to succeed
     */
    function quorumVotes() external view returns (uint256);
}
