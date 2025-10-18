# Web3-Lottery-Smart-Contracts
Lottery systems in solidity (for ethereum, polygon, BNB chain)


## Table of Contents

* [Overview](#overview)
* [Features](#features)
* [Architecture](#architecture)
* [Comparison: Simple vs Chainlink VRF](#comparison-simple-vs-chainlink-vrf)
* [Setup & Deployment](#setup--deployment)
* [Usage](#usage)
* [Security Considerations](#security-considerations)
* [License](#license)

---

## Overview

This repository contains **two versions of a Lottery smart contract** built with Solidity ^0.8.3.

1. **Simple Lottery** – Uses **on-chain pseudo-randomness** (`block.prevrandao` + `block.timestamp`) for selecting a winner.
2. **Chainlink VRF Lottery** – Uses **Chainlink VRF** for provably fair and tamper-proof random winner selection.

Both allow players to enter by sending ETH, and the manager can pick a winner.

---

## Features

| Feature             | Simple Lottery             | Chainlink VRF Lottery                                  |
| ------------------- | -------------------------- | ------------------------------------------------------ |
| Minimum Entry       | 0.1 ETH                    | 0.1 ETH                                                |
| Randomness          | Pseudo-random (block data) | Provably random (Chainlink VRF)                        |
| Manager Controlled  | ✅                          | ✅                                                      |
| Event Logging       | Optional                   | ✅ (PlayerEntered, RandomnessRequested, WinnerSelected) |
| Multiple Rounds     | ✅                          | ✅                                                      |
| Secure for Mainnet  | ❌                          | ✅                                                      |
| Educational/Testing | ✅                          | ✅                                                      |

---

## Architecture

### 1. Simple Lottery

* **Manager**: deployer who can pick winner.
* **Players**: dynamic array of participants.
* **Randomness**: `random()` function combines `block.prevrandao`, `block.timestamp`, and players array.
* **Winner Selection**: `pickWinner()` transfers full contract balance to a pseudo-random player.

### 2. Chainlink VRF Lottery

* **Manager**: deployer who can request a winner.
* **Players**: dynamic array of participants.
* **Randomness**: Uses Chainlink VRF for **verifiable randomness**.
* **Winner Selection**: `fulfillRandomWords()` automatically picks and pays the winner.
* **Events**: Tracks player entry, randomness requests, and winner selection.
* **Subscription Required**: Funded with LINK on Chainlink-supported networks.

---

## Comparison of Simple vs Chainlink VRF

| Aspect              | Simple Lottery                    | Chainlink VRF Lottery            |
| ------------------- | --------------------------------- | -------------------------------- |
| Randomness Security | Weak, can be influenced by miners | Strong, verifiable               |
| Gas Cost            | Low                               | Higher (due to VRF calls)        |
| Deployment Target   | Local or testnets                 | Testnets or mainnet              |
| Suitable For        | Learning, demos                   | Production, real money lotteries |

---

## Setup & Deployment

### Simple Lottery

1. Open [Remix IDE](https://remix.ethereum.org/).
2. Copy `SimpleLottery.sol`.
3. Compile with Solidity ^0.8.3.
4. Deploy on **Remix VM**, **local Hardhat**, or testnet.
5. Manager is set to the deployer.

### Chainlink VRF Lottery

1. Create a **Chainlink VRF subscription**: [https://vrf.chain.link/](https://vrf.chain.link/)
2. Fund the subscription with test LINK.
3. Add your deployed contract as a **consumer**.
4. Use **Sepolia Testnet VRF values**:

```solidity
uint64 subscriptionId = YOUR_SUBSCRIPTION_ID;
address vrfCoordinator = 0x75e0b56eA0b4817b5cFb26f1a0F89f8E3e0E70b9;
bytes32 keyHash = 0x474e34a077df58807dbe9c93f59c8e68a5f8c45bde3b0aa3a76c7e6cbb2f42d5;
```

5. Deploy the contract.
6. Manager calls `requestRandomWinner()` to trigger the draw.

---

## Usage

### Enter Lottery

```solidity
lottery.enter{value: 0.1 ether}();
```

### Pick Winner

* **Simple Lottery:**

```solidity
lottery.pickWinner();
```

* **Chainlink VRF Lottery (Manager Only):**

```solidity
lottery.requestRandomWinner();
```

Winner is automatically selected when VRF fulfills the request.

### Check Players

```solidity
lottery.getPlayers();
```

### Check Contract Balance

```solidity
lottery.getBalance();
```

### Events (Chainlink VRF Lottery)

* `PlayerEntered(address player, uint amount)`
* `RandomnessRequested(uint256 requestId)`
* `WinnerSelected(address winner, uint amount)`

---

## Security Considerations

| Aspect         | Simple Lottery               | Chainlink VRF Lottery           |
| -------------- | ---------------------------- | ------------------------------- |
| Randomness     | Weak, miners can influence   | Strong, verifiable              |
| Access Control | Only manager can pick winner | Only manager can request VRF    |
| Reentrancy     | Safe with `.transfer()`      | Safe with `.transfer()`         |
| Testnet Usage  | Recommended                  | Recommended; ensure enough LINK |
| Mainnet Ready  | ❌                            | ✅                               |

---

## License

MIT License.


