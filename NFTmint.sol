pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

contract NFTLazyMint is EIP712{

    IERC721 NFT ; 
    address mpadress ; 
    mapping(uint => bool) private tokens;
    address owner;

    struct NFTVoucher {
    uint256 tokenId;
    uint256 minPrice; //To allow the creator to set a price when redeem function is used, value is greater than zero.
    string uri;
    bytes signature;
    }

    function createVoucher(tokenId, uri, minPrice){
        minPrice = 0;
        voucher = {tokenId, uri, minPrice}

    }

    const lazyminter = new LazyMinter({ myDeployedContract.address, signerForMinterAccount })


    function mint(uint tokenId) public {
        require(!tokens[tokenId], "Token already exists");

        //Mint new token
        tokens[tokenId] = true;
    }


}