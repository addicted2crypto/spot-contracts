// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Plots is ERC721URIStorage, Ownable {
    
    mapping(uint256 => bool) public claimed;
    uint256 public currentSupply;
    uint256 public maxSupply;
    
    constructor() ERC721("Spot Plot", "PLOT") {
        maxSupply = 610;
    }

    function claim(uint256 NFTombstoneId, uint256 plotId) public {
        require(currentSupply < maxSupply, "All NFTs have been claimed");
        require(!claimed[NFTombstoneId], "This NFTombstone has already been used to claim a plot");
        require(_isApprovedOrOwner(msg.sender, NFTombstoneId), "You are not the owner or approved to use this NFT");
        require(ownerOf(plotId) == address(0), "This new NFT has already been claimed");

        // Mint the new NFT to the caller
        _safeMint(msg.sender, plotId);
        
        // Set the claimed flag for the original NFT
        claimed[NFTombstoneId] = true;
        
        // Associate the original NFT ID with the new NFT ID
        _setTokenURI(plotId, string(abi.encodePacked("https://example.com/nft/", uint2str(originalNFTId))));
        
        currentSupply++;
    }
    
    function setMaxSupply(uint256 _maxSupply) public onlyOwner {
        require(_maxSupply > currentSupply, "New max supply must be greater than current supply");
        maxSupply = _maxSupply;
    }
}
