import {ethers} from "hardhat";
import {Contract} from "ethers";
import {expect} from "chai";

describe('NFTMarketPlace', function () {
    let market: Contract;
    let nftFactory: Contract;
    let owner: { address: any; }, addr1, addr2, addr3, addr4;

    beforeEach(async function () {
        [owner, addr1, addr2, addr3, addr4] = await ethers.getSigners();

        const treasury =  owner;
        const Market = await ethers.getContractFactory("NFTMarketPlace");
        market = await Market.deploy(treasury.address);
        await market.deployed();


        const NFTFactory = await ethers.getContractFactory("NFTFactory");
        nftFactory = await NFTFactory.deploy(market.address);
        await nftFactory.deployed();

        console.log(`NFT market place deployed to ${market.address}`);
        console.log(`NFT Factory contract deployed to ${nftFactory.address}`);
    });


    it('should create a new NFTMarketOrder if the nft is available', async function () {
        //Mint a new NFT
        const nft = await nftFactory.mintToken("https://myurl.com/myasset.png");


        //Match your expectations
        expect(await market.createNFTMarketOrder(nftFactory.address, 1, ethers.utils.parseEther('0.1'), {
            value: ethers.utils.parseEther('0.05')
        })).to.emit(market, 'MarketNFTOrderCreated').withArgs(
            nftFactory.address,
            1,
            owner.address,
            ethers.utils.parseEther('0.1'),
            ethers.utils.parseEther('0.05'),
            false
        )

    })
})