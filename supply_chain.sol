// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BareMinimumSupplyChain {

    uint256 private nextItemId = 1;

    mapping(uint256 => address) public itemOwners;

    function createItem() public returns (uint256 newItemId) {
        newItemId = nextItemId;
        itemOwners[newItemId] = msg.sender;
        nextItemId++;
    }

    function transferItem(uint256 _itemId, address _newOwner) public {
        address currentOwner = itemOwners[_itemId];
        require(currentOwner != address(0), "Item does not exist");
        require(currentOwner == msg.sender, "Caller is not the owner");
        require(_newOwner != address(0), "Invalid new owner address");

        itemOwners[_itemId] = _newOwner;
    }
}
