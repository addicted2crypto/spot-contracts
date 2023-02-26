// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract MyNFT is ERC721URIStorage, Ownable {
    using SafeMath for uint256;
    uint256 public constant LEVEL_THRESHOLD = 20;
    IERC1155 public externalContract;
    uint256 private nonce = 0;

    constructor(string memory name, string memory symbol, address externalContractAddress) ERC721(name, symbol) {
        externalContract = IERC1155(externalContractAddress);
    }

    function changeExternalContract(address newExternalContractAddress) external onlyOwner {
        externalContract = IERC1155(newExternalContractAddress);
    }

    function changeLevelThreshold(uint256 newLevelThreshold) external onlyOwner {
        require(newLevelThreshold > 0, "Level threshold must be greater than zero");
        LEVEL_THRESHOLD = newLevelThreshold;
    }

    function level(address owner) public view returns (uint256) {
        uint256 totalBalance = 0;
        for (uint256 i = 0; i < 2; i++) {
            totalBalance += externalContract.balanceOf(owner, i+1);
        }
        uint256 level = totalBalance.sub(totalBalance.mod(LEVEL_THRESHOLD)).div(LEVEL_THRESHOLD).add(1);
        if (level > 5) {
            level = 5;
        }
        return level;
    }

    function mint(address to) public {
        uint256 tokenId = uint256(keccak256(abi.encodePacked(nonce, block.timestamp, to)));
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, tokenURI(tokenId));
        nonce++;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        uint256 level = level(ownerOf(tokenId));
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(), "/", level.toString(), ".json")) : "";
    }
}
