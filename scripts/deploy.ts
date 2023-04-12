import { ethers } from "hardhat";

async function main() {

  const treasury =  (await ethers.getSigners())[0];
  const Market = await ethers.getContractFactory("NFTMarketPlace");
  const market = await Market.deploy(treasury.address);
  await market.deployed();


  const NFTFactory = await ethers.getContractFactory("NFTFactory");
  const nftFactory = await NFTFactory.deploy(market.address);
  await nftFactory.deployed();
  console.log(`NFT market place deployed to ${market.address}`);
  console.log(`NFT Factory contract deployed to ${nftFactory.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
