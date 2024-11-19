require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const ALCHEMY_API_KEY = process.env.ALCHEMY_API_KEY;
const AMOY_PRIVATE_KEY = process.env.AMOY_PRIVATE_KEY;
const AMOYSCAN_API_KEY = process.env.AMOYSCAN_API_KEY;

module.exports = {
  solidity: {
    compilers: [
      { version: "0.8.20" },
      { version: "0.5.16" }
    ]
  },
  networks: {
    amoy: {
      url: "https://polygon-amoy.g.alchemy.com/v2/RUgCAtG51FJUJKH8rcQlGxn4T0E0tk-L",
      accounts: [AMOY_PRIVATE_KEY]
    }
  },
  etherscan: {
    apiKey: AMOYSCAN_API_KEY,
    customChains: [
      {
        network: "amoy",
        chainId: 80002,
        urls: {
          apiURL: "https://api-amoy.polygonscan.com/api",
          browserURL: "https://amoy.polygonscan.com"
        }
      }
    ]
  }
};
