const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("TreasureHunt", function () {
  // Fixture to deploy the TreasureHunt contract
  async function deployTreasureHuntFixture() {
    const [owner, player1, player2] = await ethers.getSigners();
    const TreasureHunt = await ethers.getContractFactory("TreasureHunt");
    const treasureHunt = await TreasureHunt.deploy({ value: ethers.parseEther("100") });

    console.log("Deployed address", treasureHunt.address);

    return { treasureHunt, owner, player1, player2 };
  }

  describe("Deployment", function () {
    it("Should set the correct grid size", async function () {
      const { treasureHunt } = await loadFixture(deployTreasureHuntFixture);
      const gridSize = await treasureHunt.GRID_SIZE();
      expect(gridSize.toString()).to.equal("10");
    });

    it("Should set the winner to the null address", async function () {
      const { treasureHunt } = await loadFixture(deployTreasureHuntFixture);
      const winnerAddress = await treasureHunt.winner();
      expect(winnerAddress).to.equal(
        "0x0000000000000000000000000000000000000000"
      );
    });

    it("Should set initial treasure position", async function () {
      const { treasureHunt } = await loadFixture(deployTreasureHuntFixture);
      expect(await treasureHunt.getTreasurePosition()).to.be.lt(100);
    });
  });

  describe("Game Mechanics", function () {
    it("Should allow a player to move", async function () {
      const { treasureHunt, player1 } = await loadFixture(deployTreasureHuntFixture);
      await expect(
        treasureHunt.connect(player1).move(1, { value: ethers.parseEther("1.0") })
      )
        .to.emit(treasureHunt, "PlayerMoved")
        .withArgs(player1.address, 1);
    });

    it("Should revert if insufficient ether is sent", async function () {
      const { treasureHunt, player1 } = await loadFixture(deployTreasureHuntFixture);
      await expect(
        treasureHunt.connect(player1).move(1, { value: ethers.parseEther("0") })
      ).to.be.revertedWith("Must send ETH to participate.");
    });

    it("Should revert if move is to an invalid position", async function () {
      const { treasureHunt, player1 } = await loadFixture(deployTreasureHuntFixture);
      await expect(
        treasureHunt.connect(player1).move(101, { value: ethers.parseEther("1.0") })
      ).to.be.revertedWith("Invalid move.");
    });

    it("Should not allow a player to move twice in the same round", async function () {
      const { treasureHunt, player1 } = await loadFixture(deployTreasureHuntFixture);

      await treasureHunt.connect(player1).move(1, { value: ethers.parseEther("1.0") });

      await expect(
        treasureHunt.connect(player1).move(2, { value: ethers.parseEther("1.0") })
      ).to.be.revertedWith("Player has already moved this round.");
    });

    it("Should update treasure position when player moves to a multiple of 5", async function () {
      const { treasureHunt, player1 } = await loadFixture(deployTreasureHuntFixture);
      const initialPosition = await treasureHunt.getTreasurePosition();
      await treasureHunt.connect(player1).move(5, { value: ethers.parseEther("1.0") });
      expect(await treasureHunt.getTreasurePosition()).to.not.equal(initialPosition);
    });

    it("Should emit GameWon event when player finds the treasure", async function () {
      const { treasureHunt, player1 } = await loadFixture(deployTreasureHuntFixture);
      const treasurePosition = await treasureHunt.getTreasurePosition();
      await expect(
        treasureHunt.connect(player1).move(treasurePosition, { value: ethers.parseEther("1.0") })
      )
        .to.emit(treasureHunt, "GameWon")
        .withArgs(player1.address, anyValue);
    });
  });

  describe("Reward Sharing", function () {
    it("Should declare a winner and distribute rewards", async function () {
      const { treasureHunt, player1 } = await loadFixture(deployTreasureHuntFixture);

      const initialBalance = await ethers.provider.getBalance(player1.address);

      const treasurePosition = await treasureHunt.getTreasurePosition();
      await treasureHunt.connect(player1).move(treasurePosition, { value: ethers.parseEther("1.0") });

      expect(await treasureHunt.winner()).to.equal(player1.address);

      const finalBalance = await ethers.provider.getBalance(player1.address);

      expect(finalBalance).to.be.gt(initialBalance); 
    });
  });
});
