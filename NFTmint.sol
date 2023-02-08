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

    function redeem(address redeemer, NFTVoucher calldata voucher) public payable returns (uint256) {
        // make sure signature is valid and get the address of the signer
        address signer = _verify(voucher);
   
        // make sure that the signer is authorized to mint NFTs
        require(hasRole(MINTER_ROLE, signer), "Signature invalid or unauthorized");

        // make sure that the redeemer is paying enough to cover the buyer's cost
        require(msg.value >= voucher.minPrice, "Insufficient funds to redeem");

        // first assign the token to the signer, to establish provenance on-chain
        _mint(signer, voucher.tokenId);
        _setTokenURI(voucher.tokenId, voucher.uri);
        
        // transfer the token to the redeemer
        _transfer(signer, redeemer, voucher.tokenId);

        // record payment to signer's withdrawal balance
        pendingWithdrawals[signer] += msg.value;

        return voucher.tokenId;
  }


}
