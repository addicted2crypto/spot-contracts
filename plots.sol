// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Plots is ERC721 {
    uint256 public maxSupply;
    uint256 public currentSupply;
    mapping (uint256 => bool) public claimed;

    constructor(string memory name, string memory symbol, uint256 _maxSupply) ERC721(name, symbol) {
        maxSupply = _maxSupply;
        currentSupply = 0;
    }

   function claim(uint256 tombstoneID, uint256 plotID) public {
    require(currentSupply < maxSupply, "All NFTs have been claimed");
    require(!claimed[originalNFTId], "This NFTombstone has already been used to claim");
    require(_isApprovedOrOwner(msg.sender, originalNFTId), "You are not the owner or approved to use this NFT");
    require(ownerOf(newNFTId) == address(0), "ThisPLOT has already been claimed");

    // Mint the new NFT to the caller
    _safeMint(msg.sender, newNFTId);
    
    // Set the claimed flag for the original NFT
    claimed[tombstoneID] = true;
    
    // Associate the original NFT ID with the new NFT ID
    _setTokenURI(newNFTId, string(abi.encodePacked("https://example.com/nft/", uint2str(originalNFTId))));
    
    currentSupply++;
}


    function uint2str(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}
