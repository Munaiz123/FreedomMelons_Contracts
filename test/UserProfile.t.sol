// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/UserProfile.sol";

contract UserProfileTest is Test {
    UserProfile private userProfile;
    address private user1;
    address private user2;
    address private trustedForwarder;

    function setUp() public {
        trustedForwarder = address(0x3333333333333333333333333333333333333333);
        userProfile = new UserProfile(trustedForwarder);
        user1 = address(0x1111111111111111111111111111111111111111);
        user2 = address(0x2222222222222222222222222222222222222222);
    }

    function testSetUserProfile() public {
        vm.prank(user1);
        userProfile.setUserProfile("John", "Doe");
        
        (string memory firstName, string memory lastName) = userProfile.getUserProfile(user1);
        assertEq(firstName, "John");
        assertEq(lastName, "Doe");
        assertTrue(userProfile.userExists(user1));
    }

    function testGetNonExistentUser() public {
        vm.expectRevert("User profile does not exist");
        userProfile.getUserProfile(user2);
    }

    function testUpdateExistingProfile() public {
        vm.startPrank(user1);
        userProfile.setUserProfile("John", "Doe");
        userProfile.setUserProfile("Jane", "Smith");
        vm.stopPrank();

        (string memory firstName, string memory lastName) = userProfile.getUserProfile(user1);
        assertEq(firstName, "Jane");
        assertEq(lastName, "Smith");
    }

    function testMultipleUsers() public {
        vm.prank(user1);
        userProfile.setUserProfile("John", "Doe");

        vm.prank(user2);
        userProfile.setUserProfile("Jane", "Smith");

        (string memory firstName1, string memory lastName1) = userProfile.getUserProfile(user1);
        assertEq(firstName1, "John");
        assertEq(lastName1, "Doe");

        (string memory firstName2, string memory lastName2) = userProfile.getUserProfile(user2);
        assertEq(firstName2, "Jane");
        assertEq(lastName2, "Smith");
    }

    function testUserExists() public {
        assertFalse(userProfile.userExists(user1));

        vm.prank(user1);
        userProfile.setUserProfile("John", "Doe");

        assertTrue(userProfile.userExists(user1));
        assertFalse(userProfile.userExists(user2));
    }

    function testEmptyName() public {
        vm.prank(user1);
        userProfile.setUserProfile("", "");

        (string memory firstName, string memory lastName) = userProfile.getUserProfile(user1);
        assertEq(firstName, "");
        assertEq(lastName, "");
    }


    function testEventEmission() public {
        vm.expectEmit(true, false, false, true);
        emit UserProfile.ProfileUpdated(user1, "John", "Doe");
        
        vm.prank(user1);
        userProfile.setUserProfile("John", "Doe");
    }

    function testFuzzSetUserProfile(string memory firstName, string memory lastName) public {
        vm.assume(bytes(firstName).length > 0 && bytes(lastName).length > 0);
        
        vm.prank(user1);
        userProfile.setUserProfile(firstName, lastName);
        
        (string memory retrievedFirstName, string memory retrievedLastName) = userProfile.getUserProfile(user1);
        assertEq(retrievedFirstName, firstName);
        assertEq(retrievedLastName, lastName);
    }

    function testDeleteUser() public {
        vm.prank(user1);
        userProfile.setUserProfile("John", "Doe");
        
        assertTrue(userProfile.userExists(user1));
        
        vm.prank(user1);
        userProfile.deleteUser(user1);
        
        assertFalse(userProfile.userExists(user1));
        
        vm.expectRevert("User profile does not exist");
        userProfile.getUserProfile(user1);
    }

    function testDeleteNonExistentUser() public {
        vm.expectRevert("User profile does not exist");
        userProfile.deleteUser(user2);
    }

    function testDeleteUserTwice() public {
        vm.startPrank(user1);
        userProfile.setUserProfile("Jane", "Doe");
        userProfile.deleteUser(user1);
        
        vm.expectRevert("User profile does not exist");
        userProfile.deleteUser(user1);
        vm.stopPrank();
    }

    function testDeleteUserEventEmission() public {
        vm.prank(user1);
        userProfile.setUserProfile("John", "Doe");

        vm.expectEmit(true, false, false, false);
        emit UserProfile.ProfileDeleted(user1);
        
        vm.prank(user1);
        userProfile.deleteUser(user1);
    }
}