const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const OWNER_ADDRESS = "0x970eA4a7F0F0872B5aC888f00B82E07f2aC31799";

module.exports = buildModule("GameMarketplaceModule", (m) => {
  // Step 1: Deploy MockUSDT
  const mockUSDT = m.contract("MockUSDT");

  // Step 2: Deploy GameToken
  const gameToken = m.contract("GameToken", [OWNER_ADDRESS]);

  // Step 3: Deploy DepositAndGetGameTokenContract
  const depositAndGetGameToken = m.contract(
    "DepositAndGetGameTokenContract",
    [OWNER_ADDRESS, gameToken, mockUSDT, mockUSDT]
  );

  // Step 4: Deploy TreasureHunt
  const treasureHunt = m.contract(
    "TreasureHunt",
    [gameToken, OWNER_ADDRESS]
  );

  return { mockUSDT, gameToken, depositAndGetGameToken, treasureHunt };
});
