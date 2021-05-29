require('dotenv').config();

const HDWalletProvider = require('@truffle/hdwallet-provider');
const INFURA = `https://rinkeby.infura.io/v3/${process.env.INFURA_PROJECT_ID}`;

const MNEUMONICS = process.env.MNEUMONICS;

function getMnemonic(network) {
    // For live deployments use a specific Ephimera key
    if (network === 'mainnet') {
        return process.env.MAINNET_PK || '';
    }
    return process.env.PROTOTYPE_PK || '';
};

module.exports = {
  compilers: {
    solc: {
      version: "^0.8.0",
      settings: {
        optimizer: {
          enabled: true, // Default: false
          runs: 900,     // Number of times you expect the contract to run. Default: 200. TODO: increase this before deploying the stable version.
        },
      },
    },
  },
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*",
    },
    rinkeby: {
      provider: function () {
        return new HDWalletProvider(MNEUMONICS, INFURA);
      },
      network_id: 4,
      gas: 9278228,
      gasPrice: 25000000000, // 25 Gwei. default = 100 gwei = 100000000000
      skipDryRun: true,
    },
  },
  // mocha: {
  //     reporter: 'eth-gas-reporter',
  //     reportOptions: {
  //         currency: 'USD',
  //     }
  // }
};