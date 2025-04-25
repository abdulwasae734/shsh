// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BareMinimumMultiSigWallet {
    address[] public owners;
    uint public approvalsNeeded;
    mapping(address => bool) public isOwner;

    address payable public proposedRecipient;
    uint public approvalCount;
    mapping(address => bool) public hasApproved;
    bool public withdrawalProposed;

    constructor(address[] memory _owners, uint _approvalsNeeded) {
        require(_owners.length > 0 && _approvalsNeeded > 0 && _approvalsNeeded <= _owners.length, "Invalid setup");
        for (uint i = 0; i < _owners.length; i++) {
            require(_owners[i] != address(0) && !isOwner[_owners[i]], "Invalid owner");
            isOwner[_owners[i]] = true;
        }
        owners = _owners;
        approvalsNeeded = _approvalsNeeded;
    }

    receive() external payable {}

    function proposeWithdrawal(address payable _recipient) public {
        require(isOwner[msg.sender], "Not owner");
        require(_recipient != address(0), "Invalid recipient");
        require(!withdrawalProposed, "Proposal active");

        proposedRecipient = _recipient;
        withdrawalProposed = true;
        approvalCount = 0;
        for (uint i = 0; i < owners.length; i++) {
            hasApproved[owners[i]] = false;
        }
        hasApproved[msg.sender] = true;
        approvalCount = 1;

        if (approvalCount >= approvalsNeeded) {
            _executeWithdrawal();
        }
    }

    function approveWithdrawal() public {
        require(isOwner[msg.sender], "Not owner");
        require(withdrawalProposed, "No proposal");
        require(!hasApproved[msg.sender], "Already approved");

        hasApproved[msg.sender] = true;
        approvalCount++;

        if (approvalCount >= approvalsNeeded) {
            _executeWithdrawal();
        }
    }

    function _executeWithdrawal() internal {
        uint balance = address(this).balance;
        require(balance > 0, "Zero balance");

        address payable recipient = proposedRecipient;
        withdrawalProposed = false;
        proposedRecipient = payable(address(0));

        (bool success, ) = recipient.call{value: balance}("");
        require(success, "Transfer failed");
    }
}

contract BareMinimumTimeLockedWallet {
    address public owner;
    uint public unlockTime;

    constructor(uint _unlockTimestamp) {
        require(_unlockTimestamp > block.timestamp, "Unlock time in past");
        owner = msg.sender;
        unlockTime = _unlockTimestamp;
    }

    receive() external payable {}

    function withdraw() public {
        require(msg.sender == owner, "Not owner");
        require(block.timestamp >= unlockTime, "Still locked");
        uint balance = address(this).balance;
        require(balance > 0, "Zero balance");

        (bool success, ) = payable(owner).call{value: balance}("");
        require(success, "Transfer failed");
    }
}

contract BareMinimumEscrow {
    address public buyer;
    address payable public seller;
    address public arbiter;
    bool public fundsReleased;

    constructor(address payable _seller, address _arbiter) payable {
        require(msg.value > 0, "Zero deposit");
        require(_seller != address(0) && _arbiter != address(0), "Invalid party");
        buyer = msg.sender;
        seller = _seller;
        arbiter = _arbiter;
        fundsReleased = false;
    }

    function releaseFunds() public {
        require(!fundsReleased, "Released");
        require(msg.sender == buyer || msg.sender == arbiter, "Not authorized");

        fundsReleased = true;

        uint balance = address(this).balance;
        (bool success, ) = seller.call{value: balance}("");
        require(success, "Transfer failed");
    }
}
