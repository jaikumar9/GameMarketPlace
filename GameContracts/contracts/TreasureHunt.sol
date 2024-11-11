// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract TreasureHunt is ReentrancyGuard {
    uint8 public constant GRID_SIZE = 10;
    uint8 public constant TOTAL_CELLS = GRID_SIZE * GRID_SIZE;
    uint8 internal treasurePosition;
    uint256 public round;
    uint256 public prizePool;
    uint256 public moveCost = 2000; // Cost of each move in tokens

    IERC20 public gameToken;
    address public owner;
    address public winner;

    mapping(address => uint8) public playerPositions;
    mapping(address => bool) public hasMoved;
    mapping(address => bool) public isPlayer;
    address[] public players;

    event PlayerMoved(address indexed player, uint8 position);
    event TreasureMoved(uint8 newPosition);
    event GameWon(address indexed winner, uint256 prize);

    constructor(address _tokenAddress, address _ownerAddress ) {
        gameToken = IERC20(_tokenAddress);
        owner = _ownerAddress;
        treasurePosition = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.number))) % TOTAL_CELLS);
        round = 1;
    }

    modifier onlyOncePerRound() {
        require(!hasMoved[msg.sender], "Player has already moved this round.");
        _;
    }

    modifier validMove(uint8 newPosition) {
        require(newPosition < TOTAL_CELLS, "Invalid move.");
        require(isAdjacent(playerPositions[msg.sender], newPosition), "Move must be adjacent.");
        _;
    }

    function move(uint8 newPosition) public nonReentrant onlyOncePerRound validMove(newPosition) {
        // Transfer tokens from player to the contract as the move cost
        require(gameToken.transferFrom(msg.sender, address(this), moveCost), "Token transfer failed");

        if (!isPlayer[msg.sender]) {
            players.push(msg.sender);
            isPlayer[msg.sender] = true;
        }

        playerPositions[msg.sender] = newPosition;
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
            treasurePosition = _getRandomAdjacentPosition(treasurePosition);
        } else if (_isPrime(playerPosition)) {
            treasurePosition = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % TOTAL_CELLS);
        }
        emit TreasureMoved(treasurePosition);
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

    // Reset the game for the next round
    _resetGame();
}

    function _resetGame() internal {
        round++;
        treasurePosition = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.number))) % TOTAL_CELLS);

        for (uint256 i = 0; i < players.length; i++) {
            hasMoved[players[i]] = false;
        }
    }

    function _getRandomAdjacentPosition(uint8 currentPosition) internal view returns (uint8) {
        uint8[] memory adjacentPositions = _getAdjacentPositions(currentPosition);
        return adjacentPositions[uint256(keccak256(abi.encodePacked(block.timestamp))) % adjacentPositions.length];
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

    function isAdjacent(uint8 pos1, uint8 pos2) internal pure returns (bool) {
        return (pos1 >= GRID_SIZE && pos1 - GRID_SIZE == pos2) ||
               (pos1 < TOTAL_CELLS - GRID_SIZE && pos1 + GRID_SIZE == pos2) ||
               (pos1 % GRID_SIZE != 0 && pos1 - 1 == pos2) ||
               ((pos1 + 1) % GRID_SIZE != 0 && pos1 + 1 == pos2);
    }

    function getTreasurePosition() public view returns (uint8) {
        return treasurePosition;
    }

    function getGameState() public view returns (address, uint256) {
        return (winner, prizePool);
    }
}
