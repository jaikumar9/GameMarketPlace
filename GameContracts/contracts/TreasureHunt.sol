// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol"; // To fetch token decimals
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract TreasureHunt is ReentrancyGuard {
    uint8 public constant GRID_SIZE = 10;
    uint8 public constant TOTAL_CELLS = GRID_SIZE * GRID_SIZE;
    uint8 internal treasurePosition;
    uint256 public round;
    uint256 public prizePool;
    uint256 public moveCost; // Cost of each move in tokens
    uint8 public tokenDecimals; // Decimals of the token

    IERC20 public gameToken;
    address public owner;
    address public winner;

    mapping(address => uint8) public playerPositions;
    mapping(address => bool) public hasMoved;
    mapping(address => bool) public isPlayer;
    mapping(uint8 => bool) public isOccupied; // Tracks if a position is occupied by a player
    address[] public players;

    event RewardDistributed(
        address indexed winner,
        uint256 winnerShare,
        uint256 ownerShare,
        uint256 nextRoundShare
    );

    event PlayerMoved(address indexed player, uint8 position);
    event GameWon(address indexed winner, uint256 prize);

    constructor(address _tokenAddress, address _ownerAddress) {
        gameToken = IERC20(_tokenAddress);
        owner = _ownerAddress;

        // Dynamically fetch the token's decimals
        tokenDecimals = IERC20Metadata(_tokenAddress).decimals();
        moveCost = 2000 * 10**tokenDecimals; // Adjust for token decimals

        // Initialize treasure position
        treasurePosition = uint8(uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.number,
            block.prevrandao,
            msg.sender,
            address(this)
        ))) % TOTAL_CELLS);

        
        round = 1;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    modifier onlyOncePerRound() {
        require(!hasMoved[msg.sender], "Player has already moved this round.");
        _;
    }

    modifier validMove(uint8 newPosition) {
        require(newPosition < TOTAL_CELLS, "Invalid move.");
        _;
    }

    function move(uint8 newPosition) public onlyOncePerRound validMove(newPosition) {
        // Transfer tokens from player to the contract as the move cost
        require(!isOccupied[newPosition], "Position already occupied.");
        require(gameToken.transferFrom(msg.sender, address(this), moveCost), "Token transfer failed");

        if (!isPlayer[msg.sender]) {
            players.push(msg.sender);
            isPlayer[msg.sender] = true;
        }

        playerPositions[msg.sender] = newPosition;
        isOccupied[newPosition] = true; // Mark the position as occupied
        prizePool += moveCost;
        hasMoved[msg.sender] = true;

        emit PlayerMoved(msg.sender, newPosition);

        if (newPosition == treasurePosition) {
            _winGame();
        } else {
            _moveTreasure(newPosition);
        }
    }

    function _moveTreasure(uint8 playerPosition) internal {
        if (playerPosition % 5 == 0) {
            treasurePosition = _getRandomAdjacentVacantPosition(treasurePosition);
        } else if (_isPrime(playerPosition)) {
            treasurePosition = _getRandomVacantPosition(); // Pick any random vacant position
        }
    }

    function _getRandomAdjacentVacantPosition(uint8 currentPosition) internal view returns (uint8) {
        uint8[] memory adjacentPositions = _getAdjacentPositions(currentPosition);
        uint8[] memory vacantPositions = _filterVacantPositions(adjacentPositions);

        require(vacantPositions.length > 0, "No vacant adjacent positions available.");

        return vacantPositions[uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.number,
            block.prevrandao,
            msg.sender,
            address(this),
            round,
            currentPosition
        ))) % vacantPositions.length];
    }

    function _filterVacantPositions(uint8[] memory positions) internal view returns (uint8[] memory) {
        uint8[] memory vacantPositions = new uint8[](positions.length);
        uint8 vacantCount = 0;

        for (uint8 i = 0; i < positions.length; i++) {
            if (!isOccupied[positions[i]]) {
                vacantPositions[vacantCount++] = positions[i];
            }
        }

        // Resize the array to the number of vacant positions
        uint8[] memory result = new uint8[](vacantCount);
        for (uint8 i = 0; i < vacantCount; i++) {
            result[i] = vacantPositions[i];
        }

        return result;
    }

    function _getRandomVacantPosition() internal view returns (uint8) {
        uint8[] memory allPositions = new uint8[](TOTAL_CELLS);
        uint8 vacantCount = 0;

        for (uint8 i = 0; i < TOTAL_CELLS; i++) {
            if (!isOccupied[i]) {
                allPositions[vacantCount++] = i;
            }
        }

        require(vacantCount > 0, "No vacant positions available.");

        return allPositions[uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.number,
            block.prevrandao,
            msg.sender,
            address(this),
            round,
            vacantCount
        ))) % vacantCount];
    }

    function _getAdjacentPositions(uint8 position) internal pure returns (uint8[] memory) {
        uint8 count = 0;

        if (position >= GRID_SIZE) count++;
        if (position < TOTAL_CELLS - GRID_SIZE) count++;
        if (position % GRID_SIZE != 0) count++;
        if ((position + 1) % GRID_SIZE != 0) count++;

        uint8[] memory adjacent = new uint8[](count);
        count = 0;

        if (position >= GRID_SIZE) adjacent[count++] = position - GRID_SIZE;
        if (position < TOTAL_CELLS - GRID_SIZE) adjacent[count++] = position + GRID_SIZE;
        if (position % GRID_SIZE != 0) adjacent[count++] = position - 1;
        if ((position + 1) % GRID_SIZE != 0) adjacent[count++] = position + 1;

        return adjacent;
    }

    function _isPrime(uint8 num) internal pure returns (bool) {
        if (num < 2) return false;
        for (uint8 i = 2; i * i <= num; i++) {
            if (num % i == 0) return false;
        }
        return true;
    }
 
    function _winGame() internal nonReentrant {
        winner = msg.sender;
        uint256 reward = (prizePool * 90) / 100;
        uint256 ownerShare = (prizePool * 2) / 100;
        uint256 carryOver = (prizePool * 8) / 100;

        // Update prize pool to carry over before making transfers
        prizePool = carryOver;

        // Transfer the 90% reward to the winner
        require(gameToken.transfer(winner, reward), "Token transfer to winner failed");

        // Transfer the 2% share to the owner
        require(gameToken.transfer(owner, ownerShare), "Token transfer to owner failed");

        emit GameWon(winner, reward);

        // Emit RewardDistributed event
        emit RewardDistributed(winner, reward, ownerShare, carryOver);

        // Reset the game for the next round
        _resetGame();
    }

    function _resetGame() internal {
        round++;
        treasurePosition = uint8(uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.number,
            block.prevrandao,
            msg.sender,
            address(this),
            round
        ))) % TOTAL_CELLS); // Move treasure to a new random position

        // Reset player states
        for (uint256 i = 0; i < players.length; i++) {
            hasMoved[players[i]] = false;
            isOccupied[playerPositions[players[i]]] = false; // Mark the previous position as unoccupied
        }

        // Clear the occupied positions mapping
        for (uint8 i = 0; i < TOTAL_CELLS; i++) {
            isOccupied[i] = false; // Mark all positions as vacant
        }

        // Clear player positions after reset
        for (uint8 i = 0; i < players.length; i++) {
            playerPositions[players[i]] = 255; // Reset to an invalid position
        }
    }

    function addTokensToPrizePool(uint256 amount) external onlyOwner nonReentrant {
        require(gameToken.transferFrom(msg.sender, address(this), amount), "Token transfer failed");
        prizePool += amount;
    }

    function withdrawTokensFromPrizePool(uint256 amount) external onlyOwner nonReentrant {
        require(amount <= prizePool, "Not enough tokens in the prize pool");
        prizePool -= amount;
        require(gameToken.transfer(owner, amount), "Token transfer failed");
    }

    function getTreasurePosition() public view onlyOwner returns (uint8) {
        return treasurePosition;
    }

    function getGameState() public view returns (address, uint256) {
        return (winner, prizePool);
    }
}
