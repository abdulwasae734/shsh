// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EtherTransfer {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {}

    function sendEther(address payable recipient, uint amount) public {
        require(msg.sender == owner, "Only owner can send Ether");
        recipient.transfer(amount);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
