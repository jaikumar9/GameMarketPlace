# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a Hardhat Ignition module that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/Lock.js
```
npx hardhat ignition deploy ignition/modules/deploy.js --network amoy --verify
npx hardhat ignition verify chain-80002 
npx hardhat test --network amoy


Deployed Addresses and Verification Status

GameMarketplaceModule#GameToken - 0x7Abb3E5250648990b7d408D6b62D47cec9BAf314      
GameMarketplaceModule#MockUSDT - 0xCA66834cD90fF801f8D0D52Abe37FF2c90853067       
GameMarketplaceModule#DepositAndGetGameTokenContract - 0x4CdB4C0deeD0D2e3b5079b178AACE5dEEd7decd5
GameMarketplaceModule#TreasureHunt - 0xf3492b0d663FCEd2214d78fe81fA07ac071Ce1A7 