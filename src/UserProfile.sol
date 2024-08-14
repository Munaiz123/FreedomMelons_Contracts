// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/metatx/ERC2771Context.sol";

contract UserProfile is ERC2771Context {
    struct UserInfo {
        string firstName;
        string lastName;
    }

    mapping(address => UserInfo) private userProfiles;
    mapping(address => bool) private _userExists;

    event ProfileUpdated(address indexed user, string firstName, string lastName);
    event ProfileDeleted(address indexed user);

    constructor(address trustedForwarder) ERC2771Context(trustedForwarder) {}

    function setUserProfile(string memory _firstName, string memory _lastName) public {
        address sender = _msgSender();
        userProfiles[sender] = UserInfo(_firstName, _lastName);
        _userExists[sender] = true;
        emit ProfileUpdated(sender, _firstName, _lastName);
    }

    function getUserProfile(address _user) public view returns (string memory firstName, string memory lastName) {
        require(_userExists[_user], "User profile does not exist");
        UserInfo memory profile = userProfiles[_user];
        return (profile.firstName, profile.lastName);
    }

    function userExists(address _user) public view returns (bool) {
        return _userExists[_user];
    }

    function deleteUser(address _user) public {
        require(_userExists[_user], "User profile does not exist");
        delete userProfiles[_user];
        _userExists[_user] = false;
        emit ProfileDeleted(_user);
    }

    function _msgSender() internal view override returns (address sender) {
        return ERC2771Context._msgSender();
    }

    function _msgData() internal view override returns (bytes calldata) {
        return ERC2771Context._msgData();
    }
}