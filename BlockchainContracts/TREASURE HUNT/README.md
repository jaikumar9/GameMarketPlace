# Treasure Hunt

## Overview

Deployed Address - 0x6889Ab4C76B9CE32360d397EbA3F65F143876981 On Sepolia Testnet.

EtherScan Link https://sepolia.etherscan.io/address/0x6889Ab4C76B9CE32360d397EbA3F65F143876981#code

**Treasure Hunt** is a decentralized blockchain game designed for Ethereum. Players compete to find a hidden treasure located on a 10x10 grid. The treasure's position updates dynamically based on player interactions and specific rules, adding an element of strategy and chance.

## Objective

The primary objective of the game is to locate the hidden treasure by moving across the grid. The treasure's location changes based on player moves, and the first player to land on the treasure's location wins.

## Game Rules

1. **Grid Layout:**
   - The game operates on a 10x10 grid.
   - Each position on the grid is identified by a unique number ranging from 0 to 99.

2. **Players:**
   - Any Ethereum address can participate by sending a specified amount of ETH to the contract.
   - Each player is allowed to make one move per turn.

3. **Treasure Position:**
   - The treasure starts at a random position, determined by the hash of the block number when the contract is deployed.
   - Players can view the current position of the treasure using the `getTreasurePosition` public function. 

   **Warning:** The `getTreasurePosition` function is included for testing purposes only. In a production environment, this function should be removed or modified to ensure that the treasure position remains hidden to maintain the integrity of the game.

4. **Movement Rules:**
   - Players can move to any adjacent grid position (up, down, left, right) from their current location.
   - Treasure Movement:
     - If a player moves to a position that is a multiple of 5, the treasure moves to a random adjacent position.
     - If a player moves to a position that is a prime number, the treasure jumps to a new random position on the grid.

5. **Winning Condition:**
   - A player wins the game if they move to the grid position where the treasure is currently located.

6. **Rewards:**
   - The winner receives 90% of the total ETH balance held by the contract.
   - The remaining 10% is retained in the contract for future game rounds.

## Additional Features

- **Public Treasure Position:** The current position of the treasure can be accessed using the `getTreasurePosition` function for testing. 

- **Security Considerations:** The contract uses `ReentrancyGuard` to prevent reentrancy attacks and includes checks to ensure valid moves and proper player actions.

- **Gas Efficiency:** The contract has been optimized to minimize gas costs while maintaining the core functionality of the game.

## How to Play

1. **Deploy the Contract:**
   - Deploy the Treasure Hunt smart contract on the Ethereum network.

2. **Participate:**
   - To participate, send ETH to the contract address and call the `move` function with the desired grid position.

3. **Make a Move:**
   - Ensure you send ETH when making a move. You can only move to an adjacent position unless you are at a multiple of 5 or a prime number.

4. **Check Treasure Position:**
   - Use the `getTreasurePosition` function to check the current location of the treasure. 

   **Warning:** This function is for testing only. In a production environment, this should be removed or secured to keep the treasure location hidden.

5. **Winning the Game:**
   - If you move to the position where the treasure is located, you win and receive 90% of the contract's ETH balance.

## Testing

- **Unit Tests:** Comprehensive unit tests have been written to ensure the contract's functionality, including edge cases such as treasure movement and player actions.

- **Test Coverage:**
  - Validate grid size and initial conditions.
  - Test player movement and adherence to game rules.
  - Ensure correct updating of the treasure position.
  - Verify that winners receive the appropriate rewards.

## Contributing

Contributions are welcome! If you have suggestions or improvements, please open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact

For any questions, feedback, or further information, please contact [Your Contact Information].

*************************************************************

Hardhat Deploy = npx hardhat ignition deploy ./ignition/modules/deploy.js --network localhost

Sepolia Deploy = npx hardhat ignition deploy ./ignition/modules/deploy.js --network sepolia

Test = npx hardhat test