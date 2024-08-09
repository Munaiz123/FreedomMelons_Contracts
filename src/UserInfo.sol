// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract UserInfo is Ownable {
    struct User {
        string name;
        string email;
        string tShirtSize;
        uint256[] nftsMinted;
    }

    mapping(address => User) public users;
    address[] public userAddresses;

    event UserAdded(address indexed userAddress, string name, string email);
    event UserUpdated(address indexed userAddress, string name, string email);
    event NFTMinted(address indexed userAddress, uint256 tokenId);

    constructor() Ownable(msg.sender) {}

    function addUser(address _userAddress, string memory _name, string memory _email, string memory _tShirtSize) public onlyOwner {
        require(bytes(users[_userAddress].name).length == 0, "User already exists");
        
        users[_userAddress] = User(_name, _email, _tShirtSize, new uint256[](0));
        userAddresses.push(_userAddress);
        
        emit UserAdded(_userAddress, _name, _email);
    }

    function updateUser(address _userAddress, string memory _name, string memory _email, string memory _tShirtSize) public onlyOwner {
        require(bytes(users[_userAddress].name).length > 0, "User does not exist");
        
        User storage user = users[_userAddress];
        user.name = _name;
        user.email = _email;
        user.tShirtSize = _tShirtSize;
        
        emit UserUpdated(_userAddress, _name, _email);
    }

    function addNFT(address _userAddress, uint256 _tokenId) public onlyOwner {
        require(bytes(users[_userAddress].name).length > 0, "User does not exist");
        
        users[_userAddress].nftsMinted.push(_tokenId);
        
        emit NFTMinted(_userAddress, _tokenId);
    }

    function getUserInfo(address _userAddress) public view returns (string memory, string memory, string memory, uint256[] memory) {
        User memory user = users[_userAddress];
        return (user.name, user.email, user.tShirtSize, user.nftsMinted);
    }

    function getAllUsers() public view returns (address[] memory) {
        return userAddresses;
    }

    function userExists(address _userAddress) public view returns (bool) {
        return bytes(users[_userAddress].name).length > 0;
    }

    function getAllUsersWithData() public view returns (address[] memory, User[] memory) {
        User[] memory userData = new User[](userAddresses.length);
        for (uint i = 0; i < userAddresses.length; i++) {
            userData[i] = users[userAddresses[i]];
        }
        return (userAddresses, userData);
    }
}