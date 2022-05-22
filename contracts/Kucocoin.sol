// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Kucocoin {
    uint constant supply = 100000;
    address[] users;
    mapping(address => uint) index;
    mapping(address => uint256) coins;

    constructor() { 
        users.push(address(0));
        addMember();
        coins[msg.sender] += supply;
    }

    modifier onlyMembers() {
        requireMembership(msg.sender);
        _;
    }

    function requireMembership(address account) public view {
        require (index[account] > 0);
    }

    function addMember() public payable {
        require (index[msg.sender] == 0);
        users.push(msg.sender);
        index[msg.sender] = users.length;
        coins[msg.sender] = msg.value;
    }

    function register() payable public {
        require (index[msg.sender] == 0);
        index[msg.sender] = users.length;
        users.push(msg.sender);
    }

    function deposit() payable public onlyMembers {
        coins[msg.sender] += msg.value;
    }

    function transfer(address to, uint amount) public onlyMembers {
        requireMembership(to);
        address from = msg.sender;
        uint holdings = coins[from];
        require (amount <= holdings);
        coins[msg.sender] -= amount;
        coins[to] += amount;
    }

    function getBalance() external view returns (uint) {
        requireMembership(msg.sender);
        return coins[msg.sender];
    }

    function hash(string calldata data) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(data));
    }
        
}