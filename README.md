Collectible Quest System (Solidity)
Overview
This Solidity smart contract, CollectibleQuestSystem, acts as a registry and distribution mechanism for digital collectible (NFT) rewards tied to off-chain quest completion. It is designed to be a lightweight, immutable layer that guarantees rewards are securely issued to users who have completed tasks verified by a trusted authority (the contract owner).

The contract adheres to a minimalist design with no external imports (aside from the defined interface) and uses an initialize function instead of a constructor for setup.

Key Features
Owner-Controlled Completion: Only the designated contract owner (typically a secure game server or multisig wallet) can mark a quest as complete for a specific user.

Secure Claiming: Users must have a quest completed but not yet claimed before they can mint their reward.

External NFT Integration: The system interfaces with an external ERC-721 contract to execute the actual token minting, keeping the reward logic separate from the NFT contract itself.

Technical Details
Solidity Version: ^0.8.0

Initialization: Setup is done via the initialize(address nftContractAddress) function, which sets the owner and the target NFT contract address. This function can only be called once.
