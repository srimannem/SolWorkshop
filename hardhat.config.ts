import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.17",

    defaultNetwork: "local",
  networks: {
    hardhat: {
        allowUnlimitedContractSize: true
    },
    local: {
      url: "http://localhost:8545",
      accounts: ["0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"]
    },
    testnet: {
        url: "https://data-seed-prebsc-1-s1.binance.org:8545",
        accounts: [process.env.PRIVATE_KEY || "0x772e82f2ca3f8c31ec4b89e980f50f08c2124b235dade27b8ceddabf87459cf5"]
    }

  },
    etherscan: {
        apiKey: {
            bscTestnet: process.env.BSCSCAN_APIKEY || 'CWW3P8ZJAIS5PNKGVBBZM196KJCVAWF21S',
        },
    },
};

export default config;
