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

    mapping(address => uint8) public playerPositions; // Maps player to their grid position
    mapping(address => bool) public hasMoved;
    mapping(address => bool) public isPlayer;
    mapping(uint8 => bool) public isOccupied; // Tracks if a position is occupied by a player
    address[] public players;
     mapping(uint256 => mapping(address => uint8[])) public roundPlayerMoves; // Tracks moves by players per round

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
        require(!isOccupied[newPosition], "Position already occupied.");
        require(gameToken.transferFrom(msg.sender, address(this), moveCost), "Token transfer failed");

        if (!isPlayer[msg.sender]) {
            players.push(msg.sender);
            isPlayer[msg.sender] = true;
        }

        playerPositions[msg.sender] = newPosition; // Record the player's position
        roundPlayerMoves[round][msg.sender].push(newPosition); // Record the move for the round
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

        prizePool = carryOver;

        require(gameToken.transfer(winner, reward), "Token transfer to winner failed");
        require(gameToken.transfer(owner, ownerShare), "Token transfer to owner failed");

        emit GameWon(winner, reward);
        emit RewardDistributed(winner, reward, ownerShare, carryOver);

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
        ))) % TOTAL_CELLS);

        for (uint256 i = 0; i < players.length; i++) {
            hasMoved[players[i]] = false;
            isOccupied[playerPositions[players[i]]] = false;
            playerPositions[players[i]] = 255; // Reset to an invalid position
        }

     for (uint256 i = 0; i < players.length; i++) {
        playerPositions[players[i]] = 0; // Explicit reset to 0
    }
    delete players; // Clear the players array

    }

    function getRoundMoves(uint256 _round, address _player) public view returns (uint8[] memory) {
        if (roundPlayerMoves[_round][_player].length > 0) {
            // Case 1: Player has moved; return their moves
            return roundPlayerMoves[_round][_player];
        } else {
            // Case 2: Player hasn't moved; return all occupied positions
            uint8[] memory occupiedPositions = new uint8[](TOTAL_CELLS);
            uint8 count = 0;

            for (uint8 i = 0; i < TOTAL_CELLS; i++) {
                if (isOccupied[i]) {
                    occupiedPositions[count++] = i;
                }
            }

            // Resize array to remove uninitialized slots
            uint8[] memory result = new uint8[](count);
            for (uint8 i = 0; i < count; i++) {
                result[i] = occupiedPositions[i];
            }

            return result;
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

     function getPlayerPosition(address player) external view returns (uint256) {
        return playerPositions[player];
     }
        function getCurrentRound() public view returns (uint256) {
            return round;
    }
}
