// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

// A simple lottery contract where users can enter by paying Ether,
// and the manager can pick a random winner to receive the total balance.
contract Lottery {
    // Address of the contract manager (the one who deployed the contract)
    address public manager;

    // Dynamic array to store all players who entered the lottery
    address payable[] public players;

    // Constructor is executed once when the contract is deployed
    constructor() {
        // Set the contract deployer as the manager
        manager = msg.sender;
    }

    // Modifier to restrict certain functions to only the manager
    modifier restricted() {
        require(msg.sender == manager, "Only Manager can do this action");
        _;
    }

    // Modifier to ensure there is at least one player before picking a winner
    modifier moreThanOnePlayer() {
        require(players.length > 0, "No players in the lottery");
        _;
    }

    // Function to allow users to enter the lottery
    // They must send more than 0.1 Ether with their transaction
    function enter() public payable {
        require(msg.value > 0.1 ether, "Please send more than 0.1 ether to this contract");

        // Add the player’s address to the list (cast to payable type)
        players.push(payable(msg.sender));
    }

    // Private helper function to generate a pseudo-random number
    // (Note: This is NOT secure for real-world use; for production, use Chainlink VRF)
    function random() private view returns (uint) {
        // Combines block data and players array to produce a hash, then converts to uint
        return uint(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, players)));
    }

    // Manager-only function to pick a winner from the players array
    function pickWinner() public restricted moreThanOnePlayer {
        // Generate a pseudo-random index based on current players
        uint index = random() % players.length;

        // Transfer the entire contract balance to the randomly chosen player
        players[index].transfer(address(this).balance);

        // Reset the players array for the next lottery round
        players = new address payable[](0);
    }
}
