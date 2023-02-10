const { ethers } = require("ethers");
const { ethers, network } = require("hardhat")


async function buyNFT(){
  nftMarketplace = await ethers.getContract("Nftmarketplace") // Returns a new connection to a contract at contractAddressOrName with the contractInterface.

  NFTMint = await ethers.getContract("NFTLazyMint")

}