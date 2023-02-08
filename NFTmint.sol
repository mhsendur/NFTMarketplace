// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

pragma solidity ^0.8.7;

contract LazyMinting {
    uint256 public totalSupply;

    mapping (address => uint256) public balances;
    mapping (address => mapping (uint256 => bool)) public minted;

    event NewMint(address indexed _to, uint256 _tokenId);

    function mint(address _to, uint256 _tokenId) public {
        require(!minted[_to][_tokenId], "Token already minted");
        minted[_to][_tokenId] = true;
        balances[_to]++;
        totalSupply++;
        emit NewMint(_to, _tokenId);
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }
}
