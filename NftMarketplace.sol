// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NftMarketplace is ReentrancyGuard {
  struct NFT {
    address nftContractAddress; //Refers to the address location of the smart contract that manages the logic for the token.
    uint256 tokenId; //A unique instance of the smart contract.
    uint256 price;
    address payable seller;
    address payable owner;
    bool listed;
    bool sold;
  }

  event NFTListed(
    address nftContractAddress,
    uint256 tokenId,
    address seller,
    address owner,
    uint256 price
  );

  event NFTCancelled(
    address nftContractAddress,
    uint256 tokenId,
    address owner,
    address seller
  );

  event NFTBought(
    address nftContractAddress,
    uint256 tokenId,
    address owner,
    address seller,
    uint256 price
  );

//State variables
  mapping (uint => NFT) uintNFT;
  mapping (address => uintNFT)  NFTs;
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


//Functions
function listItem (address nftContractAddress, uint256 tokenId, uint256 price) 
        external notListed(nftContractAddress, tokenId, msg.sender) isOwner(nftContractAddress, tokenId, msg.sender) { // Ensuring the item is not listed and that the lister is the owner.
          //msg.sender is the buyer calling this method
          
          require(price > 0, "Price must be greater than zero");    

          //Emitting the listedNFT event.
          ERC721 nft = IERC721(nftContractAddress);
          
          require(nft.getApproved(tokenId) == address(this), "Not Approved For Marketplace") ;
          
          NFTs[nftContractAddress][tokenId] = NFT(price, msg.sender);
          emit NFTListed (msg.sender, nftContractAddress, tokenId, price);

        }
      
//Cancelling the listing of NFT from the listed NFTs
function cancelListing(address nftContractAddress, uint256 tokenId) 

  external isOwner(nftContractAddress, tokenId, msg.sender) isListed(nftContractAddress, tokenId) {
  delete (NFTs[nftContractAddress][tokenId]);

  //After the deletion the event is emitted.
  emit ItemCanceled(msg.sender, nftContractAddress, tokenId);
  }

function priceNotMet(address nftContractAddress, uint256 tokenId, NFT listedNFT, uint msg_value){
  require(NFTs[nftContractAddress][tokenId]> msg_value, "Insufficient balance, price not met !");
}

function buyItem(address nftContractAddress, uint256 tokenId) payable isListed(nftContractAddress, tokenId)  {
  require(msg.value >= nft.price, revert priceNotMet(nftContractAddress,tokenId, listedNFT.price));
  address payable buyer = payable(msg.sender);

}

function updateListing(address nftContractAddress, uint256 tokenId, uint256 newPrice)  
  isOwner( nftContractAddress,  tokenId, msg.sender)
  isListed( nftContractAddress,  tokenId){
  NFT memory nft =  NFTs[nftContractAddress][tokenId];
  nft.price = newPrice ; 
}

function withdrawProceeds( ) {
  require(proceeds[msg.sender]>0, "Insufficient balance ");
  msg.sender.transfer(proceeds[msg.sender]); 
  proceeds[msg.sender] = 0 ; 
}

function getPrice(address nftContractAddress, uint256 tokenId) {
 return NFTs[nftContractAddress][tokenId].price; 
}

}