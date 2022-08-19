require("@nomiclabs/hardhat-waffle");
require("dotenv").config({ path: "./.env" });
require("hardhat-gas-reporter");

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    version: "0.8.14",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000000,
      },
    },
  },
  networks: {
    myNetwork: {
      url: "http://localhost:5000",
    },
    goerli: {
      url: process.env.ALCHEMY_URL,
      accounts: [`0x${process.env.PRIVATE_KEY}`],
    },
  },
};
