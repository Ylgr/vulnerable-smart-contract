// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/HoneyPot.sol";
// Hacker tries to drain the Ethers stored in Bank by reentrancy.
contract Attack {
    Bank bank;

    constructor(Bank _bank) {
        bank = Bank(_bank);
    }

    fallback() external payable {
        if (address(bank).balance >= 1 ether) {
            bank.withdraw(1 ether);
        }
    }

    function attack() public payable {
        bank.deposit{value: 1 ether}();
        bank.withdraw(1 ether);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract HoneyPotTest is Test {
    uint256 public privateKey = 1234;
    address public signer;
    Bank public bank;
    address public exploiter = vm.addr(3333);
    function setUp() public {
        signer = vm.addr(privateKey);
        vm.startPrank(signer);
        HoneyPot honeyPot = new HoneyPot();
        bank = new Bank(honeyPot);
        vm.deal(signer, 10 ether);
        bank.deposit{value: 10 ether}();
        vm.stopPrank();
    }

    function test_get_in_honey_pot() public {
        vm.deal(exploiter, 1 ether);
        vm.startPrank(exploiter);
        Attack attack = new Attack(bank);
        vm.expectRevert(bytes("Failed to send Ether"));
        attack.attack{value: 1 ether}();
        vm.stopPrank();
        assertEq(address(attack).balance, 0);
    }
}