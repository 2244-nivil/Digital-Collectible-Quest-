// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// --- 1. MINIMAL EXTERNAL INTERFACE (No Imports) ---

/**
 * @dev Defines the minimal required function signature from the external ERC-721 contract.
 * This is placed outside the main contract body to satisfy Solidity's structure requirements.
 * It assumes the external NFT contract implements a way to safely mint tokens.
 */
interface MinimalERC721 {
    function safeMint(address to, uint256 tokenId) external;
}


/**
 * @title CollectibleQuestSystem
 * @dev A contract to manage a simple quest system, rewarding users with NFTs
 * (Digital Collectibles) by interacting with an external ERC-721 contract.
 *
 * This contract adheres to the request of having no imports and no constructor.
 * Initial setup must be performed via the 'initialize' function.
 */
contract CollectibleQuestSystem {

    // --- 2. STATE VARIABLES & CONSTANTS ---

    // The address of the external NFT/Collectible contract.
    MinimalERC721 private _collectibleContract;

    // The address authorized to manage the system (set contract, mark quests complete).
    address private _owner;

    // Mapping: Quest ID => Reward Token ID (The token ID to be minted upon completion)
    mapping(uint256 => uint256) public questRewards;

    // Mapping: User Address => Quest ID => Completion Status (true if the quest is complete)
    mapping(address => mapping(uint256 => bool)) public userQuestCompleted;

    // Mapping: User Address => Quest ID => Claim Status (true if the reward has been claimed)
    mapping(address => mapping(uint256 => bool)) public userQuestClaimed;

    // Hardcoded Quest IDs for this simplified example
    uint256 public constant QUEST_STARTER = 1001;
    uint256 public constant QUEST_CHAMPION = 1002;

    // --- 3. MODIFIERS & INITIALIZATION (No Constructor) ---

    error NotOwner();
    error AlreadyInitialized();
    error InvalidAddress();
    error InvalidQuestID();
    error QuestNotCompleted();
    error RewardAlreadyClaimed();

    modifier onlyOwner() {
        if (msg.sender != _owner) revert NotOwner();
        _;
    }

    /**
     * @notice Performs one-time setup of the contract in place of a constructor.
     * @param nftContractAddress The address of the external ERC-721 contract.
     */
    function initialize(address nftContractAddress) external {
        if (_owner != address(0)) revert AlreadyInitialized();
        if (nftContractAddress == address(0)) revert InvalidAddress();

        _owner = msg.sender;
        _collectibleContract = MinimalERC721(nftContractAddress);

        // Pre-define hardcoded quest rewards
        questRewards[QUEST_STARTER] = 50;  // Quest 1001 rewards NFT Token ID 50
        questRewards[QUEST_CHAMPION] = 101; // Quest 1002 rewards NFT Token ID 101

        emit Initialized(_owner, nftContractAddress);
    }

    // --- 4. CORE QUEST LOGIC ---

    /**
     * @notice Marks a specific quest as completed for a given user.
     * @dev Only the contract owner can call this, simulating external validation
     * that the user has met the quest criteria (e.g., in a game server).
     * @param user The address of the user who completed the quest.
     * @param questId The ID of the quest completed.
     */
    function markQuestComplete(address user, uint256 questId) external onlyOwner {
        if (questRewards[questId] == 0) revert InvalidQuestID();

        // Only update if it wasn't already marked complete
        if (!userQuestCompleted[user][questId]) {
            userQuestCompleted[user][questId] = true;
            emit QuestCompleted(user, questId);
        }
    }

    /**
     * @notice Allows a user to claim their reward NFT for a completed quest.
     * @param questId The ID of the quest to claim the reward for.
     */
    function claimReward(uint256 questId) external {
        address recipient = msg.sender;
        
        // 1. Check if the quest is defined
        uint256 rewardTokenId = questRewards[questId];
        if (rewardTokenId == 0) revert InvalidQuestID();

        // 2. Check if the user has completed the quest
        if (!userQuestCompleted[recipient][questId]) revert QuestNotCompleted();

        // 3. Check if the reward has already been claimed
        if (userQuestClaimed[recipient][questId]) revert RewardAlreadyClaimed();

        // Mark as claimed before calling external contract (checks against re-entrancy)
        userQuestClaimed[recipient][questId] = true; 

        // 4. Call the external NFT contract to mint the reward to the user
        // The NFT contract must grant this QuestSystem contract the Minter role.
        _collectibleContract.safeMint(recipient, rewardTokenId);

        emit RewardClaimed(recipient, questId, rewardTokenId);
    }
    
    // --- 5. EVENTS ---
    
    event Initialized(address indexed owner, address indexed nftContract);
    event QuestCompleted(address indexed user, uint256 indexed questId);
    event RewardClaimed(address indexed user, uint256 indexed questId, uint256 indexed tokenId);
}
