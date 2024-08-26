// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";

contract DonationNFT is ERC721, ERC2771Context {
    uint256 public tokenId;
    uint256 public monthlyLimit;
    uint256 public currentMonthMints;
    uint256 public currentMonth;

    struct DonationNFTInfo {
        uint256 tokenId;
        uint256 amount;
        uint256 date;
        string imageUrl;
    }

    mapping(uint256 => DonationNFTInfo) public tokenToDonationInfo;
    mapping(address => DonationNFTInfo[]) public userDonationHistory;
    mapping(address => uint256) public userMintCount;

    event NFTMinted(address indexed minter, uint256 amount, uint256 tokenId, uint256 date);
    event MonthlyLimitUpdated(uint256 newLimit);

    constructor(string memory name, string memory symbol, uint256 _initialMonthlyLimit, address trustedForwarder)
        ERC721(name, symbol)
        ERC2771Context(trustedForwarder)
    {
        tokenId = 0;
        currentMonth = block.timestamp / 30 days;
        monthlyLimit = _initialMonthlyLimit;
    }

    function setMonthlyLimit(uint256 _limit) external {
        monthlyLimit = _limit;
        emit MonthlyLimitUpdated(_limit);
    }

    function mint(uint256 _amount, string memory _imageUrl) external {
        uint256 newMonth = block.timestamp / 30 days;
        if (newMonth > currentMonth) {
            currentMonth = newMonth;
            currentMonthMints = 0;
        }

        require(currentMonthMints < monthlyLimit, "Monthly limit reached");

        tokenId++;
        _safeMint(_msgSender(), tokenId);

        DonationNFTInfo memory newDonation = DonationNFTInfo({
            tokenId: tokenId,
            amount: _amount,
            date: block.timestamp,
            imageUrl: _imageUrl
        });

        tokenToDonationInfo[tokenId] = newDonation;
        userDonationHistory[_msgSender()].push(newDonation);
        userMintCount[_msgSender()]++;
        currentMonthMints++;

        emit NFTMinted(_msgSender(), _amount, tokenId, block.timestamp);
    }

    function getUserMintCount(address user) external view returns (uint256) {
        return userMintCount[user];
    }

    function getUserDonationHistory(address user) external view returns (DonationNFTInfo[] memory) {
        return userDonationHistory[user];
    }

    function getCurrentMonthMints() external view returns (uint256) {
        return currentMonthMints;
    }

    function getRemainingMonthlyMints() external view returns (uint256) {
        return monthlyLimit > currentMonthMints ? monthlyLimit - currentMonthMints : 0;
    }

    // Override functions to support ERC2771Context
    function _msgSender() internal view override(Context, ERC2771Context) returns (address) {
        return ERC2771Context._msgSender();
    }

    function _msgData() internal view override(Context, ERC2771Context) returns (bytes calldata) {
        return ERC2771Context._msgData();
    }

    function _contextSuffixLength() internal view override(ERC2771Context, Context) returns (uint256) {
        return ERC2771Context._contextSuffixLength(); // or use Context._contextSuffixLength() if needed
    }
}