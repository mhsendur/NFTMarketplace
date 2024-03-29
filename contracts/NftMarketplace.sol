// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NftMarketplace is ReentrancyGuard {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  Counters.Counter private _itemsSold;
  Counters.Counter private _tokenId;
   
  struct NFT {
    //address nftContractAddress; //Refers to the address location of the smart contract that manages the logic for the token.
    //uint256 tokenId; //A unique instance of the smart contract.
    uint256 price;
    address seller;
    //address payable owner;
    //bool listed;
    //bool sold;
  }

  event NFTListed(
    address indexed nftContractAddress,
    uint256 indexed tokenId,
    address indexed seller,
    uint256 price
  );

  event NFTCancelled(
    address indexed nftContractAddress,
    uint256 indexed tokenId,
    address indexed seller
  );

  event NFTBought(
    address indexed nftContractAddress,
    uint256 indexed tokenId,
    address indexed seller,
    uint256 price
  );

//State variables
  mapping (uint => NFT) uintNFT;
  mapping (address => mapping(uint256 => NFT)) private  NFTs;
  mapping (address => uint256) proceeds;


//Function modifiers
 modifier isListed(address nftContractAddress, uint256 tokenId) {
    NFT memory listedNFT = NFTs[nftContractAddress][tokenId];
      require(!(listedNFT.price > 0), "NFT is not listed");    
  _; //Merge wildcard
  }

  modifier notListed(address nftContractAddress, uint tokenId, address owner) {
    NFT memory listedNFT = NFTs[nftContractAddress][tokenId];

    require((listedNFT.price > 0), "NFT is already listed");    
  _; 
  }

   modifier isOwner(address nftContractAddress, uint tokenId, address spender) {
        IERC721 nft = IERC721(nftContractAddress);
        address owner = nft.ownerOf(tokenId);

      require((spender == owner), "Spender is not the owner");    
    _;
    }  
  modifier priceNotMet(address nftContractAddress, uint256 tokenId, uint msg_value){
  require(NFTs[nftContractAddress][tokenId].price > msg_value, "Insufficient balance, price not met !");
_;
}


//Functions
function listItem (address nftContractAddress, uint256 tokenId, uint256 price) 
        external notListed(nftContractAddress, tokenId, msg.sender) isOwner(nftContractAddress, tokenId, msg.sender) { // Ensuring the item is not listed and that the lister is the owner.
          //msg.sender is the buyer calling this method
          
          require(price > 0, "Price must be greater than zero");    

          //Emitting the listedNFT event.
          IERC721 nft = IERC721(nftContractAddress);
          
          require(nft.getApproved(tokenId) == address(this), "Not Approved For Marketplace") ;
          
          NFTs[nftContractAddress][tokenId] = NFT(price, msg.sender);
          emit NFTListed (nftContractAddress, tokenId, msg.sender, price);

        }
      
//Cancelling the listing of NFT from the listed NFTs
function cancelListing(address nftContractAddress, uint256 tokenId) 

  external isOwner(nftContractAddress, tokenId, msg.sender) isListed(nftContractAddress, tokenId) {
  delete (NFTs[nftContractAddress][tokenId]);

  //After the deletion the event is emitted.
  emit NFTCancelled(nftContractAddress, tokenId, msg.sender);
  }

function buyNFT(address nftContractAddress, uint256 tokenId) external payable 
 isListed(nftContractAddress, tokenId)
 priceNotMet( nftContractAddress,  tokenId,  msg.value)  {
 // NFTs[nftContractAddress][tokenId].sold = true;
 // NFTs[nftContractAddress][tokenId].transferFrom((NFTs[nftContractAddress][tokenId].owner),msg.sender, tokenId);
 // NFTs[nftContractAddress][tokenId].seller.transfer(NFTs[nftContractAddress][tokenId].price);
 // NFTs[nftContractAddress][tokenId].owner = msg.sender;
    NFT memory nft =  NFTs[nftContractAddress][tokenId];
    proceeds[nft.seller] += msg.value;
  
  emit NFTBought(nftContractAddress, tokenId, nft.seller, nft.price);
}

function updateListing(address nftContractAddress, uint256 tokenId, uint256 newPrice) external 
  isOwner( nftContractAddress,  tokenId, msg.sender)
  isListed( nftContractAddress,  tokenId) nonReentrant{
  NFT memory nft =  NFTs[nftContractAddress][tokenId];
  if(newPrice != 0){
  nft.price = newPrice;}
}
/*
function withdrawProceeds() external {
  require(proceeds[msg.sender]>0, "Insufficient balance ");
  payable(msg.sender.call{value: proceeds}(); 
  proceeds[msg.sender] = 0 ; 
}

function getPrice(address nftContractAddress, uint256 tokenId) external {
 return NFTs[nftContractAddress][tokenId].price; 
}*/
}