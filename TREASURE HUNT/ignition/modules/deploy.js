const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("TreasureHuntModule", (m) => {
  const treasureHunt = m.contract("TreasureHunt");
  console.log("Address of TreasureHunt:", treasureHunt.address);
  return { treasureHunt };
});
