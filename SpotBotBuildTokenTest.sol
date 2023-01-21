// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";

contract SpotBotBuildToken is ERC1155Supply, Ownable {
    using Strings for uint256;

    string private baseURI;
    string public name;
    string public symbol;

    address public spotBotContract;

    mapping(uint256 => bool) public validDropTypes;

    event SetBaseURI(string indexed _baseURI);
    event AddDropType(uint256 _dropType);

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI
    ) ERC1155(_baseURI) {
        name = _name;
        symbol = _symbol;
        baseURI = _baseURI;
        validDropTypes[0] = true;
        emit SetBaseURI(baseURI);
    }

    function addDropType(uint256 _dropType) external onlyOwner {
        validDropTypes[_dropType] = true;
        emit AddDropType(_dropType);
    }

    function mintBatch(uint256[] memory ids, uint256[] memory amounts)
        external
        onlyOwner
    {
        _mintBatch(owner(), ids, amounts, "");
    }

    function airdropTokens(
        address[] memory to,
        uint256 typeId,
        uint256 amount
    ) public onlyOwner {
        require(validDropTypes[typeId], "TheSpotPFP: Invalid drop type");
        require(
            balanceOf(owner(), typeId) >= amount * to.length,
            "TheSpotPFP: Not enough to airdrop"
        );
        for (uint256 i = 0; i < to.length; i++) {
            safeTransferFrom(owner(), to[i], typeId, amount, "");
        }
    }

    function updateBaseUri(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
        emit SetBaseURI(baseURI);
    }

    // Minifridge edits start

    // only callable by the owner for security
    function setSpotBotContractAddress(address _spotBotContract)
        external
        onlyOwner
    {
        spotBotContract = _spotBotContract;
    }

    // this method will be called by the spot pfp contract
    // it will burn 1 spot drop token of a specifc type
    function burnBuildToken(uint256 typeId, address burnTokenAddress) external {
        require(msg.sender == spotBotContract, "Invalid burner address");
        //require(validDropTypes[typeId], "Only light crystals are supported");
        // from -- burnTokenAddress (spotPfpcontract)
        // id -- typeId
        // amount -- 1
        _burn(burnTokenAddress, typeId, 1);
    }

    function uri(uint256 typeId) public view override returns (string memory) {
        require(validDropTypes[typeId], "TheSpotDrops: Invalid drop type");
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, typeId.toString(), ".json"))
                : "";
    }
}
