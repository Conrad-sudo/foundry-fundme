// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    using PriceConverter for uint256;

    address payable immutable owner;
    mapping(address => uint256) public s_addressToFunds;

    address[] private s_funders;

    uint256 public immutable MINIMUM_USD;

    enum fundingStatus {
        inactive,
        active
    }

    fundingStatus private status;
    AggregatorV3Interface priceFeed;

    /*
    Network: Sepolia Testnet
    Aggregator :ETH/USD
    Address:0x694AA1769357215DE4FAC081bf1f309aDC325306
    */

    constructor(uint256 minimumUSD, address _priceFeed) {
        owner = payable(msg.sender);
        status = fundingStatus.active;
        MINIMUM_USD = minimumUSD * 10 ** 18;
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function fund() public payable {
        require(msg.value.convertEthAmountToUSD(priceFeed) >= MINIMUM_USD, "Insufficient funds");

        s_addressToFunds[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    function withdraw() public isOwner returns (bool) {
        address[] memory funders = s_funders;
        //require(address(this).balance > 0, "No funds to withdraw");
        require(status == fundingStatus.active, "Funding not active");

        for (uint256 i = 0; i < funders.length; i++) {
            delete s_addressToFunds[funders[i]];
        }

        status = fundingStatus.inactive;
        delete s_funders;
        (bool success,) = owner.call{value: address(this).balance}("");
        require(success, "Transaction Failed");
        //redeclare funder array

        return success;
    }

    function reactivateFunding() public isOwner {
        status = fundingStatus.active;
    }

    //View funcitons

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getAddressToFunds(address funder) public view returns (uint256) {
        return s_addressToFunds[funder];
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function getStatus() public view returns (fundingStatus) {
        return status;
    }

    function getFunderArrayLength() public view returns (uint256) {
        return s_funders.length;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }
}
