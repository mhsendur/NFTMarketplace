pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract NFTLazyMint is EIP712,ERC20, AccessControl{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

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

    constructor(address minter, address burner) public ERC20("MyToken", "TKN") {
        _setupRole(MINTER_ROLE, minter);
        _setupRole(BURNER_ROLE, burner);
    }

    const lazyminter = new LazyMinter(
        {myDeployedContract.address, signerForMinterAccount})

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

    address signer = _verify(voucher);

    require(hasRole(MINTER_ROLE, msg.sender), "Caller is not a minter");
            _mint(to, amount);
        }    

    _mint(signer, voucher.tokenId);
    _setTokenURI(voucher.tokenId, voucher.uri);
    _transfer(signer, redeemer, voucher.tokenId);

    pendingWithdrawals[signer] += msg.value;

    return voucher.tokenId;
  }
  
   /* function burn(address from, uint256 amount) public {
        require(hasRole(BURNER_ROLE, msg.sender), "Caller is not a burner");
        _burn(from, amount);
    }
    */
}