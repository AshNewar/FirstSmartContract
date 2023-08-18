//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {Deploy} from "../script/Deploy.s.sol";

contract FundMeTest is Test {
    uint256 num = 1;
    FundMe fundme;
    address USER = makeAddr("user");
    uint constant SendedAmount = 3 ether; //3e18
    uint constant USER_BALANCE = 10 ether; //10e18

    modifier commonFund() {
        vm.prank(USER); //set USER as sender
        fundme.fund{value: SendedAmount}();
        _;
    }

    function setUp() external {
        Deploy deploy = new Deploy();
        fundme = deploy.run();
        vm.deal(USER, USER_BALANCE);
    }

    function testDemo2() public {
        uint256 version = fundme.getVersion();
        assertEq(version, 4);
    }

    function testOwner() public {
        assertEq(fundme.getOwner(), msg.sender);
    }

    function testFund() public commonFund {
        uint amount = fundme.getAmountFoundedByAddress(USER);
        assertEq(amount, SendedAmount);
    }

    function testFundedBy() public commonFund {
        address funderAddress = fundme.getFunders(0);
        assertEq(funderAddress, USER);
    }

    function testOnlyWithdraw() public commonFund {
        vm.expectRevert();
        fundme.withdraw();
    }

    function testWithDraw() public commonFund {
        //Arrange
        uint ownerBalance = fundme.getOwner().balance;
        uint contractBalance = address(fundme).balance;
        // console.log(ownerBalance);
        // console.log(contractBalance);
        //Acc

        vm.prank(fundme.getOwner());
        fundme.withdraw();
        uint currentOwnerBalance = fundme.getOwner().balance;
        uint currentContractBalance = address(fundme).balance;

        //Assert

        assertEq(currentOwnerBalance, ownerBalance + contractBalance);
        assertEq(currentContractBalance, 0);
    }

    function testWithDrawFromMany() public commonFund {
        uint160 users = 10;
        uint160 startIndex = 2;
        for (uint160 i = startIndex; i < users; i++) {
            hoax(address(i), SendedAmount);
            fundme.fund{value: SendedAmount}();
        }

        uint ownerBalance = fundme.getOwner().balance;
        uint contractBalance = address(fundme).balance;
        console.log(ownerBalance);
        console.log(contractBalance);
        vm.prank(fundme.getOwner());
        fundme.withdraw();
        uint currentOwnerBalance = fundme.getOwner().balance;
        uint currentContractBalance = address(fundme).balance;
        console.log(currentOwnerBalance);
        console.log(currentContractBalance);

        assertEq(currentOwnerBalance, ownerBalance + contractBalance);
        assertEq(currentContractBalance, 0);
    }
}
