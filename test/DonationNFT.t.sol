// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/DonationNFT.sol";  // Adjust the path based on your folder structure

contract DonationNFTTest is Test {
    DonationNFT public donationNFT;
    address public user = address(0x1);

    function setUp() public {
        donationNFT = new DonationNFT("DonationNFT", "DNT", 10, address(this));
    }

    function testInitialValues() view public {
        assertEq(donationNFT.tokenId(), 0);
        assertEq(donationNFT.monthlyLimit(), 10);
        assertEq(donationNFT.currentMonthMints(), 0);
        assertEq(donationNFT.currentMonth(), block.timestamp / 30 days);
    }

    function testSetMonthlyLimit() public {
        donationNFT.setMonthlyLimit(20);
        assertEq(donationNFT.monthlyLimit(), 20);
    }

    function testMintNFT() public {
        vm.prank(user);  // Simulate call from user address
        donationNFT.mint(100, "ipfs://image-url");
        
        assertEq(donationNFT.tokenId(), 1);
        assertEq(donationNFT.currentMonthMints(), 1);
        assertEq(donationNFT.userMintCount(user), 1);
        
        // Access the struct from the mapping
        (uint256 tokenId, uint256 amount, uint256 date, string memory imageUrl) = donationNFT.tokenToDonationInfo(1);

        // Check the values stored in the struct
        assertEq(amount, 100);
        assertEq(tokenId, 1);
        assertEq(imageUrl, "ipfs://image-url");
        // Optionally, you can check the date, but be aware it might not be exactly equal to block.timestamp
        // assertEq(date, block.timestamp);
    }

    function testMintNFTMonthlyLimitReached() public {
        vm.prank(user);
        for (uint256 i = 0; i < 10; i++) {
            donationNFT.mint(100, "ipfs://image-url");
        }

        vm.expectRevert("Monthly limit reached");
        donationNFT.mint(100, "ipfs://image-url");
    }

    function testMintNFTNewMonthResetsLimit() public {
        // Mint up to the limit
        vm.startPrank(user);
        for (uint256 i = 0; i < 10; i++) {
            donationNFT.mint(100, "ipfs://image-url");
        }
        vm.stopPrank();

        uint256 initialMonth = donationNFT.currentMonth();

        // Fast forward time to the next month
        vm.warp(block.timestamp + 31 days);
        
        // Mint again, which should be allowed after the month reset
        vm.prank(user);
        donationNFT.mint(100, "ipfs://image-url");
        
        assertEq(donationNFT.currentMonthMints(), 1);
        assert(donationNFT.currentMonth() > initialMonth);
    }

    function testGetUserMintCount() public {
        vm.prank(user);
        donationNFT.mint(100, "ipfs://image-url");
        assertEq(donationNFT.getUserMintCount(user), 1);
    }

    function testGetUserDonationHistory() public {
        vm.prank(user);
        donationNFT.mint(100, "ipfs://image-url");
        
        DonationNFT.DonationNFTInfo[] memory history = donationNFT.getUserDonationHistory(user);
        assertEq(history.length, 1);
        assertEq(history[0].amount, 100);
    }

    function testGetCurrentMonthMints() public {
        vm.prank(user);
        donationNFT.mint(100, "ipfs://image-url");
        assertEq(donationNFT.getCurrentMonthMints(), 1);
    }

    function testGetRemainingMonthlyMints() public {
        vm.prank(user);
        donationNFT.mint(100, "ipfs://image-url");
        assertEq(donationNFT.getRemainingMonthlyMints(), 9);
    }
}
