require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.20", // First Solidity compiler version
      },
      {
        version: "0.5.16", // Second Solidity compiler version
      },
    ],
  },
};