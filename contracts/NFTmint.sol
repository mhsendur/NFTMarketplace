pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract NFTLazyMint is EIP712, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");


    mapping(uint => bool) private tokens;
    address public owner;

    struct NFTVoucher {
        uint256 tokenId;
        uint256 minPrice;
        string uri;
        bytes signature;
    }

    constructor(address minter, address burner) public {
        _setupRole(MINTER_ROLE, minter);
        _setupRole(BURNER_ROLE, burner);
    }

    function createVoucher(uint256 tokenId, string uri, uint256 minPrice) public returns (NFTVoucher, bytes) {
        NFTVoucher memory voucher = {tokenId, minPrice, uri};

        bytes32 domain = _signingDomain();
        bytes32[2] memory value = [keccak256("NFTVoucher"), voucher];
        bytes memory signature = sign(domain, keccak256(abi.encodePacked(value)));

        return (voucher, signature);
    }

    function redeem(address redeemer, NFTVoucher memory voucher, bytes memory signature) public payable {
        address signer = recoverSigner(voucher, signature);

        require(hasRole(MINTER_ROLE, msg.sender), "Caller is not a minter");
        require(signer == msg.sender, "Signer does not match msg.sender");

        _mint(redeemer, voucher.tokenId);
        _setTokenURI(voucher.tokenId, voucher.uri);

        if (msg.value >= voucher.minPrice) {
            _transfer(signer, redeemer, voucher.tokenId);
        }
    }

    function burn(uint256 tokenId) public {
        require(hasRole(BURNER_ROLE, msg.sender), "Caller is not a burner");
        _burn(msg.sender, tokenId);
    }
}
