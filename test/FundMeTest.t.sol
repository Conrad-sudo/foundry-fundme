//SPDX License-Identifier: MIT
pragma solidity ^0.8.18;

import {FundMe} from "../src/FundMe.sol";
import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    //Make a dummy address to test fund
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    address[] funders;
    //uint256 constant GAS_PRICE=1 gwei;
    //load dummy account with some funds in setUp

    function setUp() public {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, 100 ether); // load dummy account with funds here
    }

    function testMininumUSD() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18, "Minimum USD not 5");
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender, "Owner isnt msg.sender");
    }

    function testFundingStatus() public view {
        assertEq(uint256(fundMe.getStatus()), 1, "Funding status is not active");
    }

    function testFundFails() public payable {
        //this expects a revert the next line should be a failed execuatipn
        vm.expectRevert();

        fundMe.fund();
    }

    function testFundPasses() public payable funded {
        //Check if the funder is added to the addressToFunds mapping
        assertEq(fundMe.getAddressToFunds(USER), SEND_VALUE, "Funded amount is not equal to msg.value");
        //Check if the funder is added to the funders array
        assertEq(fundMe.getFunder(0), USER, "Funder is not equal to msg.sender");
    }

    function testOnlyOwnerWithdrawFails() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testOnlyOnwerWithdrawPasses() public funded {
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0, "FundMe balance is not 0");
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundMeBalance,
            "Owner balance is not equal to starting balance + starting fundMe balance"
        );
    }

    function testWithdrawFromMultipleFunders() public {
        uint160 numFunders = 10;
        uint160 startingIndex = 1;

        for (uint160 i = startingIndex; i < numFunders; i++) {
            //this performs the prank and deal cheatcode
            //creates a dummy user acount and loads with 1 ether
            hoax(address(i), 1 ether);
            fundMe.fund{value: SEND_VALUE}();
        }

        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        //shows how much gas is used in the transaction
        //uint256 gasStart=gasleft();
        //vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        //uint256 gasEnd=gasleft();
        //uint256 gasUsded=(gasStart-gasEnd)*tx.gasprice;
        //console.log("Gas used in withdraw: ", gasUsded);

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0, "FundMe balance is not 0");
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundMeBalance,
            "Owner balance is not equal to starting balance + starting fundMe balance"
        );
    }

    function testFundingStatusInactiveAfterWithdrawal() public funded {
        //Arrange
        vm.prank(fundMe.getOwner());

        //Act
        fundMe.withdraw();

        //assert
        assertEq(uint256(fundMe.getStatus()), 0, "Funding  not inactive");
    }

    function testFunderArrayIsEmptyAfterWithdrawal() public funded {
        //Arrange
        vm.prank(fundMe.getOwner());

        //Act
        fundMe.withdraw();

        //assert

        assertEq(fundMe.getFunderArrayLength(), 0, "Funder array is not empty");
    }

    function testAddressToFundsIsZeroAfterWithdrawal() public {
        uint160 numberFunders = 10;
        uint160 startingIndex = 1;

        for (uint160 i = startingIndex; i < numberFunders; i++) {
            address dummyFunder = address(i);
            funders.push(dummyFunder);
            hoax(dummyFunder, 1 ether);
            fundMe.fund{value: SEND_VALUE}();
        }
        //Arrange
        vm.prank(fundMe.getOwner());

        //Act
        fundMe.withdraw();

        //assert

        for (uint256 i = 0; i < funders.length; i++) {
            assertEq(fundMe.getAddressToFunds(funders[i]), 0, "Address to funds is not 0");
        }
    }

    function testOwnerCanReactivateFunding() public funded {
        //Arrange
        vm.startPrank(fundMe.getOwner());
        //Act
        fundMe.withdraw();
        fundMe.reactivateFunding();
        vm.stopPrank();
        //Assert
        assertEq(uint256(fundMe.getStatus()), 1, "Funding status is not active");
    }

    function testNonOwnerCantReactivateFunding() public funded {
        //Arrange
        vm.prank(fundMe.getOwner());
        //Act
        fundMe.withdraw();
        //Assert
        //this expects a revert the next line should be a failed execuatipn
        vm.expectRevert();

        fundMe.reactivateFunding();
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }
}
