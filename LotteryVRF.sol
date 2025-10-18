// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

/*
 * Secure Lottery Contract using Chainlink VRF v2
 * -----------------------------------------------
 * Players send ETH to enter the lottery.
 * The manager (deployer) triggers a random winner draw using Chainlink VRF.
 * The randomness is verifiable and tamper-proof.
 */

import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

contract LotteryVRF is VRFConsumerBaseV2 {
    // ---- Chainlink VRF Variables ----
    VRFCoordinatorV2Interface COORDINATOR; // VRF coordinator interface
    uint64 subscriptionId;                 // Subscription ID from Chainlink
    bytes32 keyHash;                       // Identifies which VRF key to use
    uint32 callbackGasLimit = 200000;      // Max gas for callback
    uint16 requestConfirmations = 3;       // Number of confirmations before fulfilling randomness
    uint32 numWords = 1;                   // How many random numbers we request

    uint256 public requestId;              // The latest VRF request ID
    uint256 public randomResult;           // The latest random number received

    // ---- Lottery Variables ----
    address public manager;                // Manager / owner of the contract
    address payable[] public players;      // List of players in current round

    // ---- Events ----
    event PlayerEntered(address indexed player, uint amount);
    event RandomnessRequested(uint256 indexed requestId);
    event WinnerSelected(address indexed winner, uint amount);

    // Constructor sets manager and initializes Chainlink VRF
    constructor(
        uint64 _subscriptionId,
        address _vrfCoordinator,
        bytes32 _keyHash
    ) VRFConsumerBaseV2(_vrfCoordinator) {
        manager = msg.sender;
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
    }

    // Modifier to restrict certain functions to only the manager
    modifier restricted() {
        require(msg.sender == manager, "Only Manager can call this");
        _;
    }

    // Allow users to join the lottery by sending > 0.1 ETH
    function enter() public payable {
        require(msg.value >= 0.1 ether, "Minimum 0.1 ETH required");
        players.push(payable(msg.sender));
        emit PlayerEntered(msg.sender, msg.value);
    }

    // Request a random number from Chainlink VRF
    // Only the manager can call this
    function requestRandomWinner() external restricted {
        require(players.length > 0, "No players in the lottery");

        // Request randomness from Chainlink VRF
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );

        emit RandomnessRequested(requestId);
    }

    // This function is automatically called by Chainlink VRF
    // when the random number is ready
    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory randomWords
    ) internal override {
        randomResult = randomWords[0];

        // Pick a winner using the random number
        uint256 index = randomResult % players.length;
        address payable winner = players[index];

        // Transfer all contract balance to the winner
        uint256 prize = address(this).balance;
        winner.transfer(prize);

        emit WinnerSelected(winner, prize);

        // Reset players for the next round
        players = new address payable[](0) ;
    }

    // Get all players in the current lottery
    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }

    // Get current contract balance
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
