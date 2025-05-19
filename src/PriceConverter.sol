// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getEthPrice(AggregatorV3Interface _priceFeed) internal view returns (uint256) {
        //AggregatorV3Interface priceFeed=AggregatorV3Interface( _interface);

        (, int256 price,,,) = _priceFeed.latestRoundData();
        // ETH/USD rate in 18 digit
        return uint256(price * 10000000000);
    }

    function convertEthAmountToUSD(uint256 ethAmount, AggregatorV3Interface _priceFeed)
        internal
        view
        returns (uint256)
    {
        uint256 ethPrice = getEthPrice(_priceFeed);

        uint256 usdAmount = (ethAmount * ethPrice) / 1e18;

        return usdAmount;
    }
}
