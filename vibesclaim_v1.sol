
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/interfaces/IERC1155.sol";

contract MyNFT is ERC721, Ownable {
    using SafeMath for uint256;

    uint256 public levelThreshold1; // configurable level thresholds
    uint256 public levelThreshold2;
    uint256 public levelThreshold3;
    uint256 public levelThreshold4;
    uint256 public levelThreshold5;

    uint256 private nonce = 0; // used for random number generation
    uint256 private maxTokenID = 10000; // maximum token ID
    uint256 private mintedTokens = 0; // number of tokens that have been minted

    IERC1155 private external1155Contract; // external ERC-1155 contract instance
    uint256 private external1155TokenID1 = 1; // external ERC-1155 token ID 1
    uint256 private external1155TokenID2 = 2; // external ERC-1155 token ID 2

    address payable public royaltyAddress;
    uint256 public royaltyPercentage = 5;

    // events
    event LevelUpdated(address indexed owner, uint256 level);

    constructor(
        string memory _name,
        string memory _symbol,
        address _external1155ContractAddress,
        uint256 _levelThreshold1,
        uint256 _levelThreshold2,
        uint256 _levelThreshold3,
        uint256 _levelThreshold4,
        uint256 _levelThreshold5
    ) ERC721(_name, _symbol) {
        external1155Contract = IERC1155(_external1155ContractAddress);
        levelThreshold1 = _levelThreshold1;
        levelThreshold2 = _levelThreshold2;
        levelThreshold3 = _levelThreshold3;
        levelThreshold4 = _levelThreshold4;
        levelThreshold5 = _levelThreshold5;
        royaltyAddress = payable(address(this));
    }

    // function to mint a token
    function mint() public {
        // check if the sender owns at least one token of external ERC-1155 contract with token ID 1
        require(external1155Contract.balanceOf(msg.sender, external1155TokenID1) > 0, "You must own at least one token of external ERC-1155 contract with token ID 1 to mint.");

        // generate a random token ID
        uint256 newTokenID = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % maxTokenID;
        nonce++;

        // check if the token ID has not been minted before
        require(!_exists(newTokenID), "Token ID already minted.");

        // mint the token
        _safeMint(msg.sender, newTokenID);
        mintedTokens++;

        // emit an event indicating the level has been updated
        emit LevelUpdated(msg.sender, getLevel(msg.sender));
    }

    // function to get the level of a user
    function getLevel(address _owner) public view returns (uint256) {
        // get the balance of external ERC-1155 contract tokens with ID 1 and ID 2
        uint256 balance1155TokenID1 = external1155Contract.balanceOf(_owner, external1155TokenID1);
        uint256 balance1155TokenID2 = external1155Contract.balanceOf(_owner, external1155TokenID2);

        // calculate the remaining balance after subtracting balance of external ERC-1155 contract token ID 2
        uint256 remainingBalance = balance1155TokenID1;
        if (balance1155TokenID2 > 0) {
            remainingBalance = remainingBalance.sub(balance1155TokenID2);
        }

        // calculate the level based on remaining balance
        uint256 level = 0;

        if (remainingBalance >= levelThreshold5) {
            level = 5;
        } else if (remainingBalance >= levelThreshold4) {
            level = 4;
        } else if (remainingBalance >= levelThreshold3) {
            level = 3;
        } else if (remainingBalance >= levelThreshold2) {
            level = 2;
        } else if (remainingBalance >= levelThreshold1) {
            level = 1;
        }

        return level;
    }

    // function to update the level of the user
    function updateLevel() public {
        // emit an event indicating the level has been updated
        emit LevelUpdated(msg.sender, getLevel(msg.sender));
    }

    // function to get the token URI
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    require(_exists(_tokenId), "URI query for nonexistent token");

    // get the level of the owner
    uint256 level = getLevel(ownerOf(_tokenId));

    // construct the token URI
    string memory baseURI = _baseURI();
    bytes memory tokenIDString = abi.encodePacked(_tokenId);
    bytes memory levelString = abi.encodePacked(level);

    bytes memory uriBytes = new bytes(
        bytes(baseURI).length + 1 + tokenIDString.length + 1 + levelString.length + 5
    );

    uint256 k = 0;
    for (uint256 i = 0; i < bytes(baseURI).length; i++) uriBytes[k++] = bytes(baseURI)[i];
    uriBytes[k++] = bytes1("/");
    for (uint256 i = 0; i < tokenIDString.length; i++) uriBytes[k++] = tokenIDString[i];
    uriBytes[k++] = bytes1("/");
    for (uint256 i = 0; i < levelString.length; i++) uriBytes[k++] = levelString[i];
    bytes memory suffixBytes = ".json";
    for (uint256 i = 0; i < suffixBytes.length; i++) uriBytes[k++] = suffixBytes[i];

    return string(uriBytes);
}


    // function to set the level thresholds
    function setLevelThresholds(
        uint256 _levelThreshold1,
        uint256 _levelThreshold2,
        uint256 _levelThreshold3,
        uint256 _levelThreshold4,
        uint256 _levelThreshold5
    ) public onlyOwner {
        levelThreshold1 = _levelThreshold1;
        levelThreshold2 = _levelThreshold2;
        levelThreshold3 = _levelThreshold3;
        levelThreshold4 = _levelThreshold4;
        levelThreshold5 = _levelThreshold5;
    }

    function royaltyInfo(uint256 _salePrice) external view  returns (address receiver, uint256 royaltyAmount) {
        uint256 royaltyValue = (_salePrice * royaltyPercentage) / 100;
        return (royaltyAddress, royaltyValue);
    }

    function setRoyaltyAddress(address payable _royaltyAddress) external onlyOwner {
        require(_royaltyAddress != address(0), "Invalid address");
        royaltyAddress = _royaltyAddress;
    }

    function setRoyaltyPercentage(uint256 _percentage) external onlyOwner {
        require(_percentage <= 100, "Invalid percentage");
        royaltyPercentage = _percentage;
    }
}
