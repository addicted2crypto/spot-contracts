// SPDX-License-Identifier: MIT


pragma solidity 0.8.11;

library Strings {
	function toString(uint256 value) internal pure returns(string memory) {
		if (value == 0) return "0";

		uint256 temp = value;
		uint256 digits;

		while (temp != 0) {
			digits++;
			temp /= 10;
		}

		bytes memory buffer = new bytes(digits);

		while (value != 0) {
			digits -= 1;
			buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
			value /= 10;
		}

		return string(buffer);
	}
}

library Address {
	function isContract(address account) internal view returns(bool) {
		return account.code.length > 0;
	}
}

library Counters {
	struct Counter {
		uint256 _value;
	}

	function current(Counter storage counter) internal view returns(uint256) {
		return counter._value;
	}

	function increment(Counter storage counter) internal {
		unchecked {
			counter._value += 1;
		}
	}

	function decrement(Counter storage counter) internal {
		uint256 value = counter._value;
		require(value > 0, "Counter: decrement overflow");

		unchecked {
			counter._value = value - 1;
		}
	}

	function reset(Counter storage counter) internal {
		counter._value = 0;
	}
}

interface IERC2981Royalties {
    function royaltyInfo(uint256 tokenID, uint256 value) external view returns(address receiver, uint256 royaltyAmount);
}

interface IERC165 {
	function supportsInterface(bytes4 interfaceID) external view returns(bool);
}

interface IERC721 is IERC165 {
	event Transfer(address indexed from, address indexed to, uint256 indexed tokenID);
	event Approval(address indexed owner, address indexed approved, uint256 indexed tokenID);
	event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

	function balanceOf(address owner) external view returns(uint256 balance);

	function ownerOf(uint256 tokenID) external view returns(address owner);

	function safeTransferFrom(address from, address to, uint256 tokenID) external;

	function transferFrom(address from, address to, uint256 tokenID) external;

	function approve(address to, uint256 tokenID) external;

	function getApproved(uint256 tokenID) external view returns(address operator);

	function setApprovalForAll(address operator, bool _approved) external;

	function isApprovedForAll(address owner, address operator) external view returns(bool);

	function safeTransferFrom(address from, address to, uint256 tokenID, bytes calldata data) external;
}

interface IERC721Metadata is IERC721 {
	function name() external view returns(string memory);

	function symbol() external view returns(string memory);

	function tokenURI(uint256 tokenID) external view returns(string memory);
}

interface IERC721Receiver {
	function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns(bytes4);
}

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {
	uint256 private constant _NOT_ENTERED = 1;
	uint256 private constant _ENTERED = 2;

	uint256 private _status;

	constructor() {
		_status = _NOT_ENTERED;
	}


	modifier nonReentrant() {
		require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

		_status = _ENTERED;

		_;

		_status = _NOT_ENTERED;
	}
}

pragma solidity ^0.8.0;

abstract contract Context {
	function _msgSender() internal view virtual returns(address) {
		return msg.sender;
	}

	function _msgData() internal view virtual returns(bytes calldata) {
		return msg.data;
	}
}

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
	address private _owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


	constructor() {
		_transferOwnership(_msgSender());
	}


	function owner() public view virtual returns(address) {
		return _owner;
	}

	modifier onlyOwner() {
		require(owner() == _msgSender(), "Ownable: caller is not the owner");
		_;
	}


	function transferOwnership(address newOwner) public virtual onlyOwner {
		require(newOwner != address(0), "Ownable: new owner is the zero address");

		_transferOwnership(newOwner);
	}

	function _transferOwnership(address newOwner) internal virtual {
		address oldOwner = _owner;

		_owner = newOwner;

		emit OwnershipTransferred(oldOwner, newOwner);
	}
}

pragma solidity ^0.8.0;

abstract contract ERC165 is IERC165 {
	function supportsInterface(bytes4 interfaceID) public view virtual override returns(bool) {
		return interfaceID == type(IERC165).interfaceId;
	}
}

pragma solidity ^0.8.0;

abstract contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
	using Address for address;
	using Strings for uint256;

	string private _name;
	string private _symbol;

	mapping(uint256 => address) private _owners;
	mapping(address => uint256) private _balances;
	mapping(uint256 => address) private _tokenApprovals;
	mapping(address => mapping(address => bool)) private _operatorApprovals;

	constructor(string memory name_, string memory symbol_) {
		_name = name_;
		_symbol = symbol_;
	}

	function supportsInterface(bytes4 interfaceID) public view virtual override(ERC165, IERC165) returns(bool) {
		return interfaceID == type(IERC721).interfaceId || interfaceID == type(IERC721Metadata).interfaceId || super.supportsInterface(interfaceID);
	}

	function balanceOf(address owner) public view virtual override returns(uint256) {
		require(owner != address(0), "ERC721: balance query for the zero address");

		return _balances[owner];
	}

	function ownerOf(uint256 tokenId) public view virtual override returns(address) {
		address owner = _owners[tokenId];

		require(owner != address(0), "ERC721: owner query for nonexistent token");

		return owner;
	}

	function name() public view virtual override returns(string memory) {
		return _name;
	}

	function symbol() public view virtual override returns(string memory) {
		return _symbol;
	}

	function tokenURI(uint256 tokenID) public view virtual override returns(string memory) {
		require(_exists(tokenID), "ERC721Metadata: URI query for nonexistent token");

		string memory baseURI = _baseURI();

		return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenID.toString())) : "";
	}

	function _baseURI() internal view virtual returns(string memory) {
		return "";
	}

	function approve(address to, uint256 tokenID) public virtual override {
		address owner = ERC721.ownerOf(tokenID);
		require(to != owner, "ERC721: approval to current owner");

		require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()), "ERC721: approve caller is not owner nor approved for all");

		_approve(to, tokenID);
	}

	function getApproved(uint256 tokenID) public view virtual override returns(address) {
		require(_exists(tokenID), "ERC721: approved query for nonexistent token");

		return _tokenApprovals[tokenID];
	}

	function setApprovalForAll(address operator, bool approved) public virtual override {
		_setApprovalForAll(_msgSender(), operator, approved);
	}

	function isApprovedForAll(address owner, address operator) public view virtual override returns(bool) {
		return _operatorApprovals[owner][operator];
	}

	function transferFrom(address from, address to, uint256 tokenID) public virtual override {
		//solhint-disable-next-line max-line-length
		require(_isApprovedOrOwner(_msgSender(), tokenID), "ERC721: transfer caller is not owner nor approved");

		_transfer(from, to, tokenID);
	}

	function safeTransferFrom(address from, address to, uint256 tokenID) public virtual override {
		safeTransferFrom(from, to, tokenID, "");
	}

	function safeTransferFrom(address from, address to, uint256 tokenID, bytes memory _data) public virtual override {
		require(_isApprovedOrOwner(_msgSender(), tokenID), "ERC721: transfer caller is not owner nor approved");

		_safeTransfer(from, to, tokenID, _data);
	}

	function _safeTransfer(address from, address to, uint256 tokenID, bytes memory _data) internal virtual {
		_transfer(from, to, tokenID);

		require(_checkOnERC721Received(from, to, tokenID, _data), "ERC721: transfer to non ERC721Receiver implementer");
	}

	function _exists(uint256 tokenID) internal view virtual returns(bool) {
		return _owners[tokenID] != address(0);
	}

	function _isApprovedOrOwner(address spender, uint256 tokenID) internal view virtual returns(bool) {
		require(_exists(tokenID), "ERC721: operator query for nonexistent token");

		address owner = ERC721.ownerOf(tokenID);

		return (spender == owner || getApproved(tokenID) == spender || isApprovedForAll(owner, spender));
	}

	function _safeMint(address to, uint256 tokenID) internal virtual {
		_safeMint(to, tokenID, "");
	}

	function _safeMint(address to, uint256 tokenID, bytes memory _data) internal virtual {
		_mint(to, tokenID);

		require(_checkOnERC721Received(address(0), to, tokenID, _data), "ERC721: transfer to non ERC721Receiver implementer");
	}

	function _mint(address to, uint256 tokenID) internal virtual {
		require(to != address(0), "ERC721: mint to the zero address");
		require(!_exists(tokenID), "ERC721: token already minted");

		_beforeTokenTransfer(address(0), to, tokenID);

		_balances[to] += 1;
		_owners[tokenID] = to;

		emit Transfer(address(0), to, tokenID);

		_afterTokenTransfer(address(0), to, tokenID);
	}

	function _burn(uint256 tokenID) internal virtual {
		address owner = ERC721.ownerOf(tokenID);

		_beforeTokenTransfer(owner, address(0), tokenID);
		_approve(address(0), tokenID);

		_balances[owner] -= 1;
		delete _owners[tokenID];

		emit Transfer(owner, address(0), tokenID);

		_afterTokenTransfer(owner, address(0), tokenID);
	}

	function _transfer(address from, address to, uint256 tokenID) internal virtual {
		require(ERC721.ownerOf(tokenID) == from, "ERC721: transfer from incorrect owner");
		require(to != address(0), "ERC721: transfer to the zero address");

		_beforeTokenTransfer(from, to, tokenID);
		_approve(address(0), tokenID);

		_balances[from] -= 1;
		_balances[to] += 1;
		_owners[tokenID] = to;

		emit Transfer(from, to, tokenID);

		_afterTokenTransfer(from, to, tokenID);
	}

	function _approve(address to, uint256 tokenID) internal virtual {
		_tokenApprovals[tokenID] = to;

		emit Approval(ERC721.ownerOf(tokenID), to, tokenID);
	}

	function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
		require(owner != operator, "ERC721: approve to caller");

		_operatorApprovals[owner][operator] = approved;

		emit ApprovalForAll(owner, operator, approved);
	}

	function _checkOnERC721Received(address from, address to, uint256 tokenID, bytes memory _data) private returns(bool) {
		if (to.isContract()) {
			try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenID, _data) returns(bytes4 retval) {
				return retval == IERC721Receiver.onERC721Received.selector;
			} catch (bytes memory reason) {
				if (reason.length == 0) revert("ERC721: transfer to non ERC721Receiver implementer");

				else {
					assembly {
						revert(add(32, reason), mload(reason))
					}
				}
			}
		}

		else return true;
	}

	function _beforeTokenTransfer(address from, address to, uint256 tokenID) internal virtual {}

	function _afterTokenTransfer(address from, address to, uint256 tokenID) internal virtual {}
}

pragma solidity ^0.8.0;
/**
 * @dev ERC721 token with storage based token URI management.
 */
abstract contract ERC721URIStorage is ERC721 {
    using Strings for uint256;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}

interface IBUILDTOKEN {
	function _burn(address burnTokenAddress, uint typeId, uint quantity) external;
	function ownerOf(uint256 tokenId) external view returns (address owner);
    function burnBuildToken(uint256 typeId, address burnTokenAddress) external;
    function balanceOf(address owner, uint256 typeId) external view returns (uint256);
	function safeTransferFrom(address from, address to, uint256 tokenID) external;
}

//SPOT Bot: Brought to you by The Spot Devs. View all of The Spot's Projects at https://thespot.art 

contract SPOTbot is ERC721URIStorage, IERC721Receiver, ReentrancyGuard, Ownable {
  using Strings for uint256;
  using Counters for Counters.Counter;

  Counters.Counter private _tokenIds;

  string private uriSuffix = ".json";
  string private baseUriExtended;

  bool public paused = true;
  bool public building = false;
  uint256 private _startTime;
  uint public _totalSupply = 5000;
  uint public _mintSupply = 3000;
  uint256 public walletMaxMint = 20;
  uint256 public _mintFee = 2 ether;

  address public treasuryWallet; 
  address public ADMIN_WALLET = 0x32bD2811Fb91BC46756232A0B8c6b2902D7d8763;  
  address public buildTokenAddress = 0xd9145CCE52D386f254917e481eB44e9943F39138; // ERC-1155 build token contract

  IBUILDTOKEN buildTokenContract = IBUILDTOKEN(buildTokenAddress);

  constructor() ERC721("SPOT Bot", "SPOTbot") {
    baseUriExtended = "ipfs://QmZVtDPexcAA7gCitJZjkuYFNefGC7qNS7qT7MbeqyPCmB/";

  }

   function setWalletMaxMint(uint256 walletMaxMint_) public onlyOwner {
    walletMaxMint = walletMaxMint_;
    }
    
   function setMintFee(uint256 mintFee_) public onlyOwner {
    _mintFee = mintFee_;
    }

  function baseURI() public view returns (string memory) {
        return baseUriExtended; 
    } 


  function setBaseURI(string memory baseURI_) external onlyOwner() {
        baseUriExtended = baseURI_;
    }


  function setMaxMint(uint _maxMint) private onlyOwner() {
    _mintSupply = _maxMint;
  }

    // MINT

    function mint(uint256 tokenAmount) external payable returns (bool) {
		require(!paused, "Minting is paused");
        require(_tokenIds.current() + tokenAmount <= _mintSupply, "Maximum Supply Minted");
        require(msg.value == _mintFee*(tokenAmount), "Invalid Minting Fee");
        require(tokenAmount <= walletMaxMint, "Max limit exceed");
        
        payable(ADMIN_WALLET).transfer(msg.value);

        for(uint i = 0; i < tokenAmount; i++) {
            _tokenIds.increment();
            uint256 newItemId = _tokenIds.current();
            _mint(msg.sender, newItemId);
            _setTokenURI(newItemId, string( abi.encodePacked(baseUriExtended, newItemId.toString(), uriSuffix) ));
        }
     
        return true;
    } 


    
    // MINT WITH ERC-1155 TOKEN RECIEVED FROM SACRIFICING

    function build(uint256 tokenAmount, uint256 buildTokenId) external payable returns (bool) {
		require(building, "Building is paused");
		require(buildTokenContract.ownerOf(buildTokenId) == _msgSender(), "You do not own a Spot Bot Build Token");
        require(_tokenIds.current() + tokenAmount >= _mintSupply, "Maximum Supply Not Yet Minted");
        require(_tokenIds.current() + tokenAmount <= _totalSupply, "Maximum Supply Built");
	    buildTokenContract._burn(buildTokenAddress, buildTokenId, tokenAmount);
        for(uint i = 0; i < tokenAmount; i++) {
            _tokenIds.increment();
            uint256 newItemId = _tokenIds.current();
            _mint(msg.sender, newItemId);
            _setTokenURI(newItemId, string( abi.encodePacked(baseUriExtended, newItemId.toString(), uriSuffix) ));
        }
      
        return true;
    } 

	function setMintSupply(uint256 mintSupply) external onlyOwner() {
        _mintSupply = mintSupply;
    }

    function setMaxSupply(uint256 maxSupply) external onlyOwner() {
        _totalSupply = maxSupply;
    }

    function remainingSupply() external view returns(uint256){
        return _totalSupply-(_tokenIds.current());
    }

	function totalSupply() public view returns(uint256){
		return _tokenIds.current();
	}
  
	function flipPausedState() public onlyOwner {
		paused = !paused;
	}

	function flipBuildState() public onlyOwner {
		building = !building;
	}

    function setTokenURI(uint256 tokenId, string memory _tokenURI) public onlyOwner {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _setTokenURI(tokenId, _tokenURI);
    } 

    function tokenURI(uint256 tokenID) public view override returns(string memory) {
        require(_exists(tokenID), "ERC721Metadata: URI query for nonexistent token");

        return string( abi.encodePacked(super.tokenURI(tokenID)) );
    
    }

    function setBuildContract(address _buildTokenAddress) external onlyOwner() {
        buildTokenAddress = _buildTokenAddress;
    }
  
    function setTreasuryWalletAddress(address _treasuryWallet)
        external
        onlyOwner
    {
        treasuryWallet = _treasuryWallet;
    }

    function supportsInterface(bytes4 interfaceID) public view override returns(bool) {
        return interfaceID == type(IERC2981Royalties).interfaceId || super.supportsInterface(interfaceID);
    }

    function royaltyInfo(uint256, uint256 value) external view returns(address, uint256) {
        return (treasuryWallet, value * 500 / 10000);
    } 

    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    } 

}
