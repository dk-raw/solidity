//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {PriceConverter} from "./PriceConverter.sol";

error NotAllowed();
error NotEnoughEth();
error TargetNotReached();
error WithdrawFail();

contract FundMe {

    address public immutable owner; //immutable is for constants set outside of the line that they are declared

    constructor() {
        owner = msg.sender;
    }

    using PriceConverter for uint256;

    uint256 public constant MIN_USD = 5e18;
    uint256 public constant TARGET_USD = 10e18;

    address[] public funders;
    mapping(address => uint256) public fundersMap;

    function fund() public payable  {
        //require(msg.value.getConversionRate() >= MIN_USD, "At least $5 in ETH required.");
        if (msg.value.getConversionRate() < MIN_USD) {
            revert NotEnoughEth();
        }
        funders.push(msg.sender);
        fundersMap[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner  {

        uint256 contractBalance = address(this).balance;

        //require(contractBalance.getConversionRate() >= TARGET_USD, "Target of kickstarter campaign not reached.");
        if (contractBalance.getConversionRate() < TARGET_USD) {
            revert TargetNotReached();
        }

        (bool callSuccess,) = payable(msg.sender).call{value: contractBalance}("");
        //require(callSuccess, "Withdraw failed.");
        if (!callSuccess) {
            revert WithdrawFail();
        }

        for (uint256 i = 0; i < funders.length; i++ ) {
            address funder = funders[i];
            fundersMap[funder] = 0;
        }
        funders = new address[](0);
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    modifier onlyOwner() {
        //require(msg.sender == owner, "Not allowed!");
        if (msg.sender != owner) {
            revert NotAllowed();
        }
        _;
    }

}