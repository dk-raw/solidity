//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice() internal view returns(uint256) {
        // sepolia 0x694AA1769357215DE4FAC081bf1f309aDC325306
        // zksync sepolia 0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF
        AggregatorV3Interface priceFeed =  AggregatorV3Interface(0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF);
        (,int256 price,,,) = priceFeed.latestRoundData();
        return uint256(price * 1e10);
    }

    function getConversionRate(uint256 eth) internal view returns(uint256) {
        uint256 price = getPrice();
        return (price * eth) / 1e18;
    }
}