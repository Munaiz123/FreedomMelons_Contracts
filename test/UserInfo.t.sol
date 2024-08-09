// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/UserInfo.sol";

contract UserInfoTest is Test {
    UserInfo public userInfo;
    address public owner;
    address public user1;
    address public user2;

    function setUp() public {
        owner = address(this);
        user1 = address(0x1);
        user2 = address(0x2);
        userInfo = new UserInfo();
    }

    function testAddUser() public {
        userInfo.addUser(user1, "Alice", "alice@example.com", "M");
        (string memory name, string memory email, string memory tShirtSize, uint256[] memory nfts) = userInfo.getUserInfo(user1);
        assertEq(name, "Alice");
        assertEq(email, "alice@example.com");
        assertEq(tShirtSize, "M");
        assertEq(nfts.length, 0);
    }

    function testFailAddExistingUser() public {
        userInfo.addUser(user1, "Alice", "alice@example.com", "M");
        userInfo.addUser(user1, "Alice", "alice@example.com", "M");
    }

    function testUpdateUser() public {
        userInfo.addUser(user1, "Alice", "alice@example.com", "M");
        userInfo.updateUser(user1, "Alicia", "alicia@example.com", "L");
        (string memory name, string memory email, string memory tShirtSize,) = userInfo.getUserInfo(user1);
        assertEq(name, "Alicia");
        assertEq(email, "alicia@example.com");
        assertEq(tShirtSize, "L");
    }

    function testFailUpdateNonExistentUser() public {
        userInfo.updateUser(user1, "Alice", "alice@example.com", "M");
    }

    function testAddNFT() public {
        userInfo.addUser(user1, "Alice", "alice@example.com", "M");
        userInfo.addNFT(user1, 1);
        userInfo.addNFT(user1, 2);
        (,,,uint256[] memory nfts) = userInfo.getUserInfo(user1);
        assertEq(nfts.length, 2);
        assertEq(nfts[0], 1);
        assertEq(nfts[1], 2);
    }

    function testFailAddNFTToNonExistentUser() public {
        userInfo.addNFT(user1, 1);
    }

    function testGetAllUsers() public {
        userInfo.addUser(user1, "Alice", "alice@example.com", "M");
        userInfo.addUser(user2, "Bob", "bob@example.com", "L");
        address[] memory users = userInfo.getAllUsers();
        assertEq(users.length, 2);
        assertEq(users[0], user1);
        assertEq(users[1], user2);
    }

    function testUserExists() public {
        assertFalse(userInfo.userExists(user1));
        userInfo.addUser(user1, "Alice", "alice@example.com", "M");
        assertTrue(userInfo.userExists(user1));
    }

    function testGetAllUsersWithData() public {
        userInfo.addUser(user1, "Alice", "alice@example.com", "M");
        userInfo.addUser(user2, "Bob", "bob@example.com", "L");
        userInfo.addNFT(user1, 1);
        
        (address[] memory addresses, UserInfo.User[] memory users) = userInfo.getAllUsersWithData();
        
        assertEq(addresses.length, 2);
        assertEq(users.length, 2);
        assertEq(addresses[0], user1);
        assertEq(addresses[1], user2);
        assertEq(users[0].name, "Alice");
        assertEq(users[1].name, "Bob");
        assertEq(users[0].nftsMinted.length, 1);
        assertEq(users[1].nftsMinted.length, 0);
    }

   function testOnlyOwnerCanAddUser() public {
        vm.prank(user1);
        vm.expectRevert();
        userInfo.addUser(user2, "Bob", "bob@example.com", "L");
    }

    function testOnlyOwnerCanUpdateUser() public {
        userInfo.addUser(user1, "Alice", "alice@example.com", "M");
        vm.prank(user1);
        vm.expectRevert();
        userInfo.updateUser(user1, "Alicia", "alicia@example.com", "L");
    }

    function testOnlyOwnerCanAddNFT() public {
        userInfo.addUser(user1, "Alice", "alice@example.com", "M");
        vm.prank(user1);
        vm.expectRevert();
        userInfo.addNFT(user1, 1);
    }
}