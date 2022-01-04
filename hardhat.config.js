require("@nomiclabs/hardhat-waffle");
// require("@nomiclabs/hardhat-etherscan");
require('dotenv').config();

module.exports = {
  solidity: '0.8.0',
  networks: {
    rinkeby: {
      url: 'https://eth-rinkeby.alchemyapi.io/v2/NDLfvP4tcTTXsLw7xL0WaxQYrrsshMCY',
      accounts: ['53f93fc930ce3322ea3890ebad10758ca0167360e324463e3ed5268fa41f6016'],
    },
    ropsten: {
      url: process.env.ROPSTEN_ALCHEMY_KEY,
      accounts: [process.env.PRIVATE_KEY],
    },
    kovan: {
      url: process.env.KOVAN_ALCHEMY_KEY,
      accounts: [process.env.PRIVATE_KEY],
    },
    mainnet: {
      chainId: 1,
      url: process.env.PROD_ALCHEMY_KEY,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
};

// etherscan: {
//   apiKey: "F68I1WV598UXWQH9BPJWNT2INTTI3A75Z6",
// }