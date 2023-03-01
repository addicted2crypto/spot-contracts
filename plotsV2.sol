pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ClaimableNFT is ERC721URIStorage, Ownable {
    
    struct ClaimableRange {
        uint256 startId;
        uint256 endId;
    }
    
    mapping(uint256 => ClaimableRange) public claimableRanges;
    mapping(uint256 => bool) public claimed;
    uint256 public currentSupply;
    uint256 public maxSupply;
    
    constructor() ERC721("ClaimableNFT", "CNFT") {
        maxSupply = 666;
    }

    function claim(uint256 originalNFTId, uint256 newNFTId) public {
        require(currentSupply < maxSupply, "All NFTs have been claimed");
        require(!claimed[originalNFTId], "This original NFT has already been used to claim");
        require(_isApprovedOrOwner(msg.sender, originalNFTId), "You are not the owner or approved to use this NFT");
        require(ownerOf(newNFTId) == address(0), "This new NFT has already been claimed");
        
        ClaimableRange memory range = claimableRanges[originalNFTId];
        require(newNFTId >= range.startId && newNFTId <= range.endId, "This new NFT ID is not claimable with this original NFT ID");

        // Mint the new NFT to the caller
        _safeMint(msg.sender, newNFTId);
        
        // Set the claimed flag for the original NFT
        claimed[originalNFTId] = true;
        
        // Associate the original NFT ID with the new NFT ID
        _setTokenURI(newNFTId, string(abi.encodePacked("https://example.com/nft/", uint2str(originalNFTId))));
        
        currentSupply++;
    }
    
    function setMaxSupply(uint256 _maxSupply) public onlyOwner {
        require(_maxSupply > currentSupply, "New max supply must be greater than current supply");
        maxSupply = _maxSupply;
    }
    
    function addClaimableRange(uint256[] memory originalNFTIds, uint256 startId, uint256 endId) public onlyOwner {
        require(startId <= endId, "Invalid range: start ID must be less than or equal to end ID");
        for (uint256 i = 0; i < originalNFTIds.length; i++) {
            claimableRanges[originalNFTIds[i]] = ClaimableRange(startId, endId);
        }
    }
}
