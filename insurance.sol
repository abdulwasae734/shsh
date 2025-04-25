// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Insurance {
    address public farmer;
    address public insurer;
    uint public rainfall; // in mm
    uint public payoutAmount = 1 ether;
    bool public isClaimed = false;

    constructor() {
        farmer = msg.sender;
        insurer = address(this); // Contract holds the money
    }

    // Anyone can fund the contract (e.g., government, company, etc.)
    function fundInsurance() public payable {}

    // Oracle (external system) updates the rainfall
    function updateRainfall(uint _rainfall) public {
        rainfall = _rainfall;
        if (rainfall < 50 && !isClaimed) {
            payout();
        }
    }

    function payout() internal {
        require(address(this).balance >= payoutAmount, "Not enough funds");
        payable(farmer).transfer(payoutAmount);
        isClaimed = true;
    }

    // Check contract balance
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
