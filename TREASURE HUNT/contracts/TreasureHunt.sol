// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract TreasureHunt is ReentrancyGuard {
    uint8 public constant GRID_SIZE = 10;
    uint8 public constant TOTAL_CELLS = GRID_SIZE * GRID_SIZE;
    uint8 internal treasurePosition;
    uint256 public round;
    uint256 public prizePool;
    address public winner;

    address[] public players;
    mapping(address => uint8) public playerPositions;
    mapping(address => bool) public hasMoved;

    event PlayerMoved(address indexed player, uint8 position);
    event TreasureMoved(uint8 newPosition);
    event GameWon(address indexed winner, uint256 prize);

    constructor() payable {
        treasurePosition = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.number))) % TOTAL_CELLS);
        round = 1;
        prizePool = msg.value;
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

    function move(uint8 newPosition) public payable nonReentrant {
        require(msg.value > 0, "Must send ETH to participate.");

        if (playerPositions[msg.sender] == 0) {
            players.push(msg.sender);
        }

        if (newPosition == treasurePosition) {
            playerPositions[msg.sender] = newPosition;
            prizePool += msg.value;
            hasMoved[msg.sender] = true;

            emit PlayerMoved(msg.sender, newPosition);
            _winGame();
        } else if (newPosition % 5 == 0) {
            playerPositions[msg.sender] = newPosition;
            prizePool += msg.value;
            hasMoved[msg.sender] = true;

            emit PlayerMoved(msg.sender, newPosition);

            _moveTreasure(newPosition);
        } else {
            require(!hasMoved[msg.sender], "Player has already moved this round.");
            require(newPosition < TOTAL_CELLS, "Invalid move.");
            require(isAdjacent(playerPositions[msg.sender], newPosition), "Move must be adjacent.");

            playerPositions[msg.sender] = newPosition;
            prizePool += msg.value;
            hasMoved[msg.sender] = true;

            emit PlayerMoved(msg.sender, newPosition);
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

    function _winGame() internal {
        winner = msg.sender;
        uint256 reward = (prizePool * 90) / 100;
        payable(winner).transfer(reward);
        prizePool = address(this).balance;
        emit GameWon(winner, reward);

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
        for (uint8 i = 2; i 
        * i <= num; i++) {
            if (num % i == 0) return false;
        }
        return true;
    }

    function isAdjacent(uint8 pos1, uint8 pos2) internal pure returns (bool) {
        bool isUp = (pos1 >= GRID_SIZE && pos1 - GRID_SIZE == pos2);
        bool isDown = (pos1 < TOTAL_CELLS - GRID_SIZE && pos1 + GRID_SIZE == pos2);
        bool isLeft = (pos1 % GRID_SIZE != 0 && pos1 - 1 == pos2);
        bool isRight = ((pos1 + 1) % GRID_SIZE != 0 && pos1 + 1 == pos2);

        return isUp || isDown || isLeft || isRight;
    }

    function getTreasurePosition() public view returns (uint8) {
        return treasurePosition;
    }

    function getGameState() public view returns (address, uint256) {
        return ( winner, prizePool);
    }
}
