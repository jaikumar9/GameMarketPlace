const { time, loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("TreasureHunt", function () {
  async function deployTreasureHuntFixture() {
    const [owner, player1, player2] = await ethers.getSigners();

    // Deploy GameToken first
    const GameToken = await ethers.getContractFactory("GameToken");
    const gameToken = await GameToken.deploy(owner.address);
    console.log("GameToken deployed to:", gameToken.target);

    // Deploy TreasureHunt
    const TreasureHunt = await ethers.getContractFactory("TreasureHunt");
    const treasureHunt = await TreasureHunt.deploy(gameToken.target, owner.address); 
    console.log("TreasureHunt deployed to:", treasureHunt.target);

    // Mint tokens to players for testing
    await gameToken.mint(player1.address, ethers.parseEther("10000"));
    await gameToken.mint(player2.address, ethers.parseEther("2000"));

    return { treasureHunt, gameToken, owner, player1, player2 };
  }

  describe("Deployment", function () {
    it("Should set the correct game token address", async function () {
      const { treasureHunt, gameToken } = await loadFixture(deployTreasureHuntFixture);
      expect(await treasureHunt.gameToken()).to.equal(await gameToken.getAddress());
    });

    it("Should set the correct owner", async function () {
      const { treasureHunt, owner } = await loadFixture(deployTreasureHuntFixture);
      expect(await treasureHunt.owner()).to.equal(owner.address);
    });

    it("Should initialize with correct grid size", async function () {
      const { treasureHunt } = await loadFixture(deployTreasureHuntFixture);
      expect(await treasureHunt.GRID_SIZE()).to.equal(10);
    });
  });

  describe("Game Mechanics", function () {
    it("Should reward the winner when they find the treasure", async function () {
      const { treasureHunt, gameToken, owner, player1, player2 } = await loadFixture(deployTreasureHuntFixture);
    
      await gameToken.connect(player1).approve(treasureHunt.target, ethers.parseEther("2000"));
      await treasureHunt.connect(player1).move(1);
    
      const tPosition = await treasureHunt.connect(owner).getTreasurePosition();
    
      await gameToken.connect(player2).approve(treasureHunt.target, ethers.parseEther("2000"));
    
      const prizePoolBefore = await treasureHunt.prizePool();
      const prizePoolBeforeEther = ethers.formatEther(prizePoolBefore);
      await treasureHunt.connect(player2).move(tPosition);
    
      const prizePoolAfter = await treasureHunt.prizePool();
      const prizePoolAfterEther = ethers.formatEther(prizePoolAfter);
      expect(Number(prizePoolAfterEther)).to.be.lessThan(Number(prizePoolBeforeEther));
    
      // Log the prize pool in Ether
      console.log("Prize Pool Before in Ether:", prizePoolBeforeEther);
      console.log("Prize Pool After in Ether:", prizePoolAfterEther);
    });
    

    it("Should allow player to make a valid move", async function () {
      const { treasureHunt, gameToken, player1 } = await loadFixture(deployTreasureHuntFixture);
      
      // Approve tokens for the game
      await gameToken.connect(player1).approve(treasureHunt.target, ethers.parseEther("2000"));
      
      await expect(treasureHunt.connect(player1).move(1))
        .to.emit(treasureHunt, "PlayerMoved")
        .withArgs(player1.address, 1);
    });

    it("Should allow player2 to make a valid move", async function () {
      const { treasureHunt, gameToken, player2 } = await loadFixture(deployTreasureHuntFixture);
         
      // Approve tokens for the game
      await gameToken.connect(player2).approve(treasureHunt.target, ethers.parseEther("2000"));
         
      await expect(treasureHunt.connect(player2).move(1))
        .to.emit(treasureHunt, "PlayerMoved")
        .withArgs(player2.address, 1);
    });

    it("Should prevent player from moving twice in same round", async function () {
      const { treasureHunt, gameToken, player2 } = await loadFixture(deployTreasureHuntFixture); 
      await gameToken.connect(player2).approve(treasureHunt.target, ethers.parseEther("2000"));
      await treasureHunt.connect(player2).move(1);
      await expect(treasureHunt.connect(player2).move(2))
        .to.be.revertedWith("Player has already moved this round.");
    });

    it("Should update prize pool after move", async function () {
      const { treasureHunt, gameToken, player1 } = await loadFixture(deployTreasureHuntFixture);
      
      await gameToken.connect(player1).approve(treasureHunt.target, ethers.parseEther("2000"));
      
      await treasureHunt.connect(player1).move(1);
      
      expect(await treasureHunt.prizePool()).to.equal(ethers.parseEther("2000"));
    });

    it("Check balance after reward share", async function () {
      const { treasureHunt, gameToken, owner, player1, player2 } = await loadFixture(deployTreasureHuntFixture);
         
      await gameToken.connect(player1).approve(treasureHunt.target, ethers.parseEther("2000"));
      await treasureHunt.connect(player1).move(1);
    
      const tPosition = await treasureHunt.connect(owner).getTreasurePosition();
    
      await gameToken.connect(player2).approve(treasureHunt.target, ethers.parseEther("2000"));
      await treasureHunt.connect(player2).move(tPosition);

      expect(await treasureHunt.prizePool()).to.equal(ethers.parseEther("320"));
      const ownerBalance = await gameToken.balanceOf(owner.address);
      expect(ownerBalance).to.equal(ethers.parseEther("80"));
      const player2Balance = await gameToken.balanceOf(player2.address);
      expect(player2Balance).to.equal(ethers.parseEther("3600"));
  });

  it("Should fail if a player moves to occupied position", async function () {
    const { treasureHunt, gameToken, owner, player1, player2 } = await loadFixture(deployTreasureHuntFixture);
    await gameToken.connect(player1).approve(treasureHunt.target, ethers.parseEther("2000"));
      await treasureHunt.connect(player1).move(1);
      await gameToken.connect(player2).approve(treasureHunt.target, ethers.parseEther("2000"));
    await expect(
      treasureHunt.connect(player2).move(1)
    ).to.be.revertedWith("Position already occupied.");
  });
});


  describe("Game State", function () {
    it("Should return correct game state", async function () {
      const { treasureHunt } = await loadFixture(deployTreasureHuntFixture);
      const [currentWinner, currentPrizePool] = await treasureHunt.getGameState();
      expect(currentWinner).to.equal(ethers.ZeroAddress);
      expect(currentPrizePool).to.equal(0);
    });

    it("Should not expose treasure position to players", async function () {
      const { treasureHunt, player1 } = await loadFixture(deployTreasureHuntFixture);
      
      await expect(
        treasureHunt.connect(player1).getTreasurePosition()
      ).to.be.revertedWith("Only the owner can call this function.");
    });

    

    it("Should check the treasure position changed after a player's move", async function () {
      const { treasureHunt, gameToken, owner, player1, player2 } = await loadFixture(deployTreasureHuntFixture);
  
      const initialTreasurePosition = await treasureHunt.connect(owner).getTreasurePosition();
      console.log("Initial Treasure Position:", initialTreasurePosition.toString());
    
     
      await gameToken.connect(player1).approve(treasureHunt.target, ethers.parseEther("2000"));
      await treasureHunt.connect(player1).move(1);
    

      const treasurePositionAfterMove = await treasureHunt.connect(owner).getTreasurePosition();
      console.log("Treasure Position After Move 1:", treasurePositionAfterMove.toString());

     await gameToken.connect(player2).approve(treasureHunt.target, ethers.parseEther("2000"));
     await treasureHunt.connect(player2).move(2);

     const treasurePositionAfterMove2 = await treasureHunt.connect(owner).getTreasurePosition();
      console.log("Treasure Position After Move 2:", treasurePositionAfterMove2.toString());
      expect(treasurePositionAfterMove).to.not.equal(treasurePositionAfterMove2);
    });
  });

  describe("Player Position Tracking", function () {
    it("Should update the player's position correctly on a valid move", async function () {
      const { treasureHunt, gameToken, player1 } = await loadFixture(deployTreasureHuntFixture);
      
      // Approve tokens for the game
      await gameToken.connect(player1).approve(treasureHunt.target, ethers.parseEther("2000"));
  
      // Player 1 moves to position 1
      await treasureHunt.connect(player1).move(1);
  
      // Verify that the player's position is recorded correctly
      const player1Position = await treasureHunt.getPlayerPosition(player1.address);
      expect(player1Position).to.equal(1);
    });
  
    it("Should return the correct position for a player after multiple moves", async function () {
      const { treasureHunt, gameToken, player1 } = await loadFixture(deployTreasureHuntFixture);
      
      // Approve tokens for the game
      await gameToken.connect(player1).approve(treasureHunt.target, ethers.parseEther("2000"));
  
      // Player 1 moves to position 3
      await treasureHunt.connect(player1).move(3);
  
      // Verify the position after the move
      const player1Position = await treasureHunt.getPlayerPosition(player1.address);
      expect(player1Position).to.equal(3);
    });
  
    it("Should return default position for a player who hasn't moved", async function () {
      const { treasureHunt, player2 } = await loadFixture(deployTreasureHuntFixture);
  
      // Query position of player 2 (hasn't moved yet)
      const player2Position = await treasureHunt.getPlayerPosition(player2.address);
      expect(player2Position).to.equal(0); 
    });
  
    it("Should handle multiple players with distinct positions", async function () {
      const { treasureHunt, gameToken, player1, player2 } = await loadFixture(deployTreasureHuntFixture);
      
      // Approve tokens for both players
      await gameToken.connect(player1).approve(treasureHunt.target, ethers.parseEther("2000"));
      await gameToken.connect(player2).approve(treasureHunt.target, ethers.parseEther("2000"));
  
      // Players move to distinct positions
      await treasureHunt.connect(player1).move(5);
      await treasureHunt.connect(player2).move(8);
  
      // Verify positions
      const player1Position = await treasureHunt.getPlayerPosition(player1.address);
      const player2Position = await treasureHunt.getPlayerPosition(player2.address);
      expect(player1Position).to.equal(5);
      expect(player2Position).to.equal(8);
    });

    it("Should reset all player positions to 0 after a player finds the treasure", async function () {
      const { treasureHunt, gameToken, owner, player1, player2 } = await loadFixture(deployTreasureHuntFixture);
      
      // Approve tokens for both players
      await gameToken.connect(player1).approve(treasureHunt.target, ethers.parseEther("2000"));
      await gameToken.connect(player2).approve(treasureHunt.target, ethers.parseEther("2000"));
    
      // Player 1 moves to position 1
      await treasureHunt.connect(player1).move(1);

      const player1Position1 = await treasureHunt.getPlayerPosition(player1.address);
      expect(player1Position1).to.equal(1);
      
      // Player 2 moves to treasure position
      const treasurePosition = await treasureHunt.connect(owner).getTreasurePosition();

      await treasureHunt.connect(player2).move(treasurePosition);

      console.log("Treasure Position:", treasurePosition.toString());

  
      // Verify positions are reset
      const player1Position = await treasureHunt.getPlayerPosition(player1.address);
      const player2Position = await treasureHunt.getPlayerPosition(player2.address);
    
      expect(player1Position).to.equal(0); // Reset to default position
      expect(player2Position).to.equal(0); // Reset to default position
    });
    
  });
  
});
