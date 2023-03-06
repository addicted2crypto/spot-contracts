pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract JPEGANONToken is ERC20 {
    using SafeMath for uint256;
    
    address public treasury;
    uint256 public totalClaimed;
    uint256 public totalAirDropped;
    uint256 public emissionRate;
    uint256 public weeklyReduction;
    uint256 public lastReduction;
    uint256 public maxClaimAmount;
    uint256 public claimInterval;

    mapping(address => bool) public claimed;
    mapping(address => uint256) public airDrops;
    mapping(address => uint256) public airDropSnapshots;

    constructor(uint256 _initialSupply, uint256 _treasuryAllocation, uint256 _emissionRate, uint256 _weeklyReduction, uint256 _maxClaimAmount, uint256 _claimInterval) ERC20("JPEGANON", "JANON") {
        require(_initialSupply > 0, "Initial supply must be greater than 0");
        require(_treasuryAllocation >= 0 && _treasuryAllocation <= 100, "Treasury allocation must be between 0 and 100");
        require(_emissionRate > 0, "Emission rate must be greater than 0");
        require(_weeklyReduction >= 0 && _weeklyReduction <= 100, "Weekly reduction must be between 0 and 100");
        require(_maxClaimAmount > 0, "Max claim amount must be greater than 0");
        require(_claimInterval > 0, "Claim interval must be greater than 0");

        treasury = msg.sender;
        totalSupply = _initialSupply.mul(2); // Initial supply is minted to the contract for distribution
        maxClaimAmount = _maxClaimAmount;
        claimInterval = _claimInterval;

        uint256 treasuryAmount = totalSupply.mul(_treasuryAllocation).div(100);
        totalSupply = totalSupply.add(treasuryAmount);
        _mint(treasury, treasuryAmount);

        _mint(address(this), _initialSupply);

        emissionRate = _emissionRate;
        weeklyReduction = _weeklyReduction;
        lastReduction = block.timestamp;

        _updateEmission();
    }

   function claim(address nftContract, uint256 tokenId) external {
    require(lastClaimed[msg.sender].add(claimInterval) <= block.timestamp, "You can only claim once every 24 hours");
    IERC721(nftContract).safeTransferFrom(msg.sender, address(this), tokenId); // ERC721 token is transferred to this contract
    require(totalClaimed.add(maxClaimAmount) <= totalSupply.div(2), "All initial claims have been completed");
    uint256 claimAmount = getClaimAmount();
    lastClaimed[msg.sender] = block.timestamp;
    totalClaimed = totalClaimed.add(claimAmount);
    _transfer(address(this), msg.sender, claimAmount);
    emit Claim(msg.sender, claimAmount);
}


function getClaimAmount() public view returns (uint256) {
    uint256 claimAmount = emissionRate.mul(maxClaimAmount);
    uint256 elapsedTime = block.timestamp.sub(lastReduction);
    uint256 reductions = elapsedTime.div(1 weeks);
    for (uint256 i = 0; i < reductions; i++) {
        claimAmount = claimAmount.mul(100 - weeklyReduction).div(100);
    }
    return claimAmount;
}

    function _updateEmission() internal {
        uint256 elapsedWeeks = (block.timestamp.sub(lastReduction)).div(7 days);
        if (elapsedWeeks > 0) {
            uint256 reductionFactor = 100 - weeklyReduction.mul(elapsedWeeks);
            emissionRate = maxClaimAmount.mul(reductionFactor).div(100);
            lastReduction = lastReduction.add(elapsedWeeks.mul(7 days));
        }
    }

    function airdrop() external {
        require(balanceOf(msg.sender) > 0, "You must hold at least one token to be eligible for an airdrop");
        require(airDropSnapshots[msg.sender] < lastReduction, "You have already claimed your airdrop for this period");
        uint256 airDropAmount = totalAirDropped.mul(balanceOf(msg.sender)).div(totalSupply);
        airDrops[msg.sender] = airDropAmount;
        airDropSnapshots[msg.sender] = block.timestamp;
    }

    function claimAirDrop() external {
        require(airDrops[msg.sender] > 0, "You do not have any airdrop to claim");
        uint256 airDropAmount = airDrops[msg.sender];
        airDrops[msg.sender] = 0;
        _transfer(address(this), msg.sender, airDropAmount);
    }
    
    function getRemainingClaimTime(address user) external view returns (uint256) {
    uint256 nextClaimTime = lastClaimed[user].add(claimInterval);
    if (block.timestamp >= nextClaimTime) {
        return 0;
    }
    return nextClaimTime.sub(block.timestamp);
}

    function distributeAirDrop() external {
        require(totalClaimed == totalSupply.div(2), "All initial claims must be completed");
        require(totalAirDropped == 0, "AirDrop has already been distributed");
        uint256 totalHolders = totalSupply.sub(balanceOf(address(this)));
        uint256 remainingAirDrop = totalSupply.mul(65).div(100);
        for (uint256 i = 0; i < totalHolders; i++) {
            address holder = tokenByIndex(i);
            uint256 holderBalance = balanceOf(holder);
            uint256 airDropAmount = remainingAirDrop.mul(holderBalance).div(totalHolders);
            airDrops[holder] = airDropAmount;
            totalAirDropped = totalAirDropped.add(airDropAmount);
        }
    }
}
