//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';

contract NFTMarketPlace is Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _orderIds;
    Counters.Counter private _tokensSold;

    // Where the listing fees goes to
    address payable treasury;

    // Listing fee
    uint256 immutable listingPrice = 0.05 ether;


    constructor(address payable treasury) {
        treasury = treasury;
    }

    struct MarketNFTOrder {
        uint tokenId;
        address nftFactory;
        address payable creator;
        address payable owner;
        uint price;
        bool sold;
    }

    // listen to events from front end applications
    event MarketNFTOrderCreated(
        uint256 indexed tokenId,
        address indexed nftFactory,
        address creator,
        address owner,
        uint256 price,
        bool sold
    );

    //Order id to the details map
    mapping(uint => MarketNFTOrder) private orderIdMap;

    //Seller should be able to list a order here
    function getListingPrice() public view returns (uint) {
        return listingPrice;
    }

    //Seller transfers his already created NFT to this neutral market place
    function createNFTMarketOrder(address nftContract, uint tokenID, uint price) public payable {
        require(msg.value == listingPrice, "Value should equal listing price");
        require(price >= 0, "postiive price expected");

        _orderIds.increment();
        uint currentOrderId = _orderIds.current();
        orderIdMap[currentOrderId] = MarketNFTOrder(
            tokenID,
            nftContract,
            payable(msg.sender),
            payable(msg.sender),
            price,
            false
        );

        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenID);

        payable(treasury).transfer(listingPrice);

        emit MarketNFTOrderCreated(
            tokenID,
            nftContract,
            msg.sender,
            msg.sender,
            price,
            false
        );
    }

    //Buyer should be able to purchase a particular order by id
    function purchaseNFTById(uint orderId) public payable {
        require(orderIdMap[orderId].price == msg.value, "Asking price not met");

        //Transfer money to the seller
        orderIdMap[orderId].owner.transfer(msg.value);

        //Change owner in our records
        orderIdMap[orderId].owner = payable(msg.sender);
        orderIdMap[orderId].sold = true;

        //Transfer the NFT to the new owner
        IERC721(orderIdMap[orderId].nftFactory).transferFrom(address(this), msg.sender, orderIdMap[orderId].tokenId);
        _tokensSold.increment();
    }

    //Fetch all the non sold items
    function getAllOrders() public view returns (MarketNFTOrder[] memory) {
        MarketNFTOrder[] memory orders = new MarketNFTOrder[](_orderIds.current() - _tokensSold.current());
        uint count = 0;
        for(uint i = 0; i < _orderIds.current(); i++) {
            if(orderIdMap[i].sold == false) {
                MarketNFTOrder storage curr = orderIdMap[i];
                orders[count] = curr;
                count++;
            }
        }
        return orders;
    }
}