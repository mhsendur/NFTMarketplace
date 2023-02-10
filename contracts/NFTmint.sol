// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
pragma experimental ABIEncoderV2;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

contract NFTLazyMint is EIP712, AccessControl, ERC721URIStorage {
    using ECDSA for bytes32;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    address public mpadress;

    mapping(uint => bool) private tokens;
    mapping (address => uint256) pendingWithdrawals;

    address public owner;

    struct NFTVoucher {
        uint256 tokenId;
        uint256 minPrice;
        string uri;
        bytes signature;

    }

constructor(address payable minter)
    ERC721("LazyNFT", "Lazy") 
    EIP712("LazyNFT-Voucher", "1") {
      _setupRole(MINTER_ROLE, minter);
    }
    
    function splitSignature(
        bytes memory sig
    ) public pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }
    
    function recoverSigner(
        bytes32 _ethSignedMessageHash,
        bytes memory _signature
    ) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }
     
    function redeem(address redeemer, NFTVoucher calldata voucher, bytes memory signature) public payable returns (uint256) {
        address signer = _verify(voucher, signature);

        require(hasRole(MINTER_ROLE, msg.sender), "Invalid signer");
        require(signer == msg.sender, "Signer does not match msg.sender");
        require(msg.value >= voucher.minPrice, "Insufficient funds to redeem");

        _mint(signer, voucher.tokenId);
        _setTokenURI(voucher.tokenId, voucher.uri);
        _transfer(signer, redeemer, voucher.tokenId);

        pendingWithdrawals[signer] += msg.value;
        return voucher.tokenId;
    }

    function _hash(NFTVoucher calldata voucher) public view returns (bytes32) {
        
        return _hashTypedDataV4(keccak256(abi.encode(
        keccak256("NFTVoucher(uint256 tokenId,uint256 minPrice,string uri)"),
        voucher.tokenId,
        voucher.minPrice,
        keccak256(bytes(voucher.uri))
        )));
    }

    function _verify(NFTVoucher calldata voucher, bytes memory signature) public view returns (address) {
        bytes32 digest = _hash(voucher);
        return digest.toEthSignedMessageHash().recover(signature);
    }

    function canWithdraw() public view returns (uint256) {
        return pendingWithdrawals[msg.sender];
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override (AccessControl, ERC721) returns (bool) {
        return ERC721.supportsInterface(interfaceId) || AccessControl.supportsInterface(interfaceId);
    }




}