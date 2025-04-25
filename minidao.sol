// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MiniDAO {
    address public manager;
    uint public totalShares;
    mapping(address => uint) public shares;

    struct Proposal {
        address payable to;
        uint amount;
        uint votes;
        uint end;
        bool done;
        mapping(address => bool) voted;
    }

    mapping(uint => Proposal) public proposals;
    uint public proposalCount;

    modifier member() {
        require(shares[msg.sender] > 0, "Not a member");
        _;
    }

    constructor() {
        manager = msg.sender;
    }

    function contribute() external payable {
        shares[msg.sender] += msg.value;
        totalShares += msg.value;
    }

    function propose(address payable to, uint amount) external member {
        Proposal storage p = proposals[++proposalCount];
        p.to = to;
        p.amount = amount;
        p.end = block.timestamp + 180;
    }

    function vote(uint id) external member {
        Proposal storage p = proposals[id];
        require(block.timestamp < p.end && !p.voted[msg.sender], "Can't vote");
        p.voted[msg.sender] = true;
        p.votes += shares[msg.sender];
    }

    function execute(uint id) external member {
        Proposal storage p = proposals[id];
        require(block.timestamp >= p.end && !p.done && p.votes > totalShares / 2, "Can't execute");
        p.done = true;
        p.to.transfer(p.amount);
    }

    function balance() external view returns (uint) {
        return address(this).balance;
    }
}
