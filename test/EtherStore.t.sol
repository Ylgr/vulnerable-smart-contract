// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/EtherStore.sol";

contract EtherStoreTest is Test {
    uint256 public privateKey = 1234;
    address public signer;
    EtherStore public etherStore;
    function setUp() public {
        signer = vm.addr(privateKey);
        vm.startPrank(signer);
        etherStore = new EtherStore();
    }

    function test_using_slither_to_detect() public {
        string[] memory cmds = new string[](2);
        cmds[0] = "slither";
        cmds[1] = "src/EtherStore.sol";
        vm.ffi(cmds);
        // detect reentrancy: Reentrancy in EtherStore.withdraw() (src/EtherStore.sol#38-46)
    }
}