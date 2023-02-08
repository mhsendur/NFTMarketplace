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
    bytes signature; //For authorisation
    }

    const lazyminter = new LazyMinter(
        {myDeployedContract.address,
        signerForMinterAccount})

    function createVoucher(tokenId, uri, minPrice = 0) {
    voucher = { tokenId, uri, minPrice }
     domain = await this._signingDomain()
    

    //Named list of all type definitions
     const types = {
      NFTVoucher: [
        {name: "tokenId", type: "uint256"},
        {name: "uri", type: "string"}, 
        {name: "minPrice", type: "uint256"}]
    }
    
    //signer._signTypedData( domain , types , value ) => Signs the typed data value with types data structure for domain using the EIP-712 specification.
    signature = await signer.signTypedData(domain, types, voucher);
    
    return {voucher, signature}
  }

    const lazyminter = new LazyMinter({ myDeployedContract.address, signerForMinterAccount })


    function mint(uint tokenId) public {
        require(!tokens[tokenId], "Token already exists");
        //Mint new token
        tokens[tokenId] = true;
    }


}
