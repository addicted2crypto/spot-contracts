// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Vibes is ERC1155, Ownable {
    address private _feeWallet;
    mapping (uint256 => uint256) private _totalSupply;
    uint256 public _mintFee = 1 ether;
    mapping (uint256 => bool) private _tokenExists;
    string private _baseURI;
   
    mapping (uint256 => address[]) private _tokenOwners;
    mapping (uint256 => bool) private _addToGudVibes;

    constructor(address feeWallet, string memory baseURI) ERC1155("Vibes") {
        _feeWallet = feeWallet;
        _baseURI = baseURI;
    }

    function addToGudVibes(uint256 tokenId, bool value) public onlyOwner {
        _addToGudVibes[tokenId] = value;
    }

    function getGudVibes(uint256 tokenId) public view returns (bool) {
        return _addToGudVibes[tokenId];
    }

    function addToTokenOwners(uint256 id, address to) internal {
        if (_tokenOwners[id].length == 0) {
            // This is the first owner for this token ID
            _tokenOwners[id].push(to);
        } else {
            bool ownerExists = false;
            for (uint256 i = 0; i < _tokenOwners[id].length; i++) {
                if (_tokenOwners[id][i] == to) {
                    // The owner already exists in the array
                    ownerExists = true;
                    break;
                }
            }
            if (!ownerExists) {
                // Add the new owner to the end of the array
                _tokenOwners[id].push(to);
            }
        }
    }

    function mint(address to, uint256 id, uint256 amount) external payable {
        require(_exists(id), "ERC1155: Cannot Mint a Token Id that doesn't exist");
        require(to != address(msg.sender), "Invalid recipient address");
        require(msg.value == _mintFee * amount, "Insufficient mint fee");

        _mint(to, id, amount, "[]");
        _totalSupply[id] += amount;
        
        addToTokenOwners(id, to);

        if (_addToGudVibes[id] == true) {
            payable(to).transfer(msg.value / 2);
            payable(_feeWallet).transfer(msg.value / 2);
        } else if (_addToGudVibes[id] == false) {
            //Select a random wallet that has been sent gudVibes and send them 50% of the badVibes minting fee
            uint256 numTokenHolders = _tokenOwners[1].length;
            if (numTokenHolders > 0) {
                uint256 randomIndex = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, id, amount))) % numTokenHolders;
                address randomHolder = _tokenOwners[1][randomIndex];
                payable(randomHolder).transfer(msg.value / 2);
            }
            payable(_feeWallet).transfer(msg.value / 2);
        } else {
            payable(_feeWallet).transfer(msg.value);
        }
    }

    function mintToOwner(uint256 id, uint256 amount, bytes memory data) external onlyOwner {
        _mint(msg.sender, id, amount, data);
        _totalSupply[id] += amount;
        if (!_tokenExists[id]) {
            _tokenExists[id] = true;
        }
    }

    function isTokenOwner(uint256 id, address owner) public view returns (bool) {
        for (uint256 i = 0; i < _tokenOwners[id].length; i++) {
            if (_tokenOwners[id][i] == owner) {
                return true;
            }
        }
        return false;
    }

    function totalSupply(uint256 id) public view returns (uint256) {
        return _totalSupply[id];
    }

    function setMintFee(uint256 mintFee) public onlyOwner {
        _mintFee = mintFee;
    }

    function _exists(uint256 tokenId) public view returns (bool) {
        return _tokenExists[tokenId];
    }

    function uint2str(uint256 _i) internal pure returns (string memory str) {
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
        str = string(bstr);
    }

    function setBaseURI(string memory baseURI_) external onlyOwner {
        _baseURI = baseURI_;
    }

    function _internalBaseURI() internal view returns (string memory) {
        return _baseURI;
    }
    function uri(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC1155Metadata: URI query for nonexistent token");

        string memory baseURI_ = _internalBaseURI();

        return bytes(baseURI_).length > 0 ? string(abi.encodePacked(baseURI_, uint2str(tokenId), ".json")) : "";
    }
}
