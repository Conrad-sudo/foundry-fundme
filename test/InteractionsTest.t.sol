//SPDX License-Identifier: MIT
pragma solidity ^0.8.18;

import {FundMe} from "../src/FundMe.sol";
import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";
import {Fund, Withdraw} from "../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;
    //Make a dummy address to test fund
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    address[] funders;
    //uint256 constant GAS_PRICE=1 gwei;
    //load dummy account with some funds in setUp

    function setUp() public {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); // load dummy account with funds here
    }

    function testUserCanFund() public {
        Fund fund = new Fund();
        fund.fund(address(fundMe));
    }

    function testUserCanWithdraw() public {
        Withdraw withdraw = new Withdraw();
        withdraw.withdraw(address(fundMe));
        assertEq(address(fundMe).balance, 0, "Balance is not 0");
    }
}
