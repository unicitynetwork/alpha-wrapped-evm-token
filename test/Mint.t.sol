// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "@openzeppelin/contracts/access/IAccessControl.sol";
import {Alpha} from "../src/Alpha.sol";
import "../src/utils/BytesUtils.sol";
import "./AbstractTest.sol";

contract MintTest is AbstractTest {
    address user = address(99);

    function testSetBurnedTotal() public {
        vm.prank(oracle);
        instance.setBurnedTotalOnPoW(user, 1000);
        assertEq(instance.getBurnedTotalOnPoW(user), 1000);
    }

    function testSetBurnedTotalTwice() public {
        vm.startPrank(oracle);
        instance.setBurnedTotalOnPoW(user, 1000);
        instance.setBurnedTotalOnPoW(user, 1001);
        assertEq(instance.getBurnedTotalOnPoW(user), 1001);
    }

    function testSetBurnedTotalCannotDecrease() public {
        vm.startPrank(oracle);
        instance.setBurnedTotalOnPoW(user, 1000);
        
        vm.expectRevert(bytes("Cannot reduce burned total"));
        instance.setBurnedTotalOnPoW(user, 999);
    }

    function testMintHappyCase() public {
        vm.prank(oracle);
        instance.setBurnedTotalOnPoW(user, 1000);

        vm.startPrank(minter);

        instance.mint(user, 500);
        assertEq(instance.getMintedSoFar(user), 500);
        assertEq(instance.balanceOf(user), 500);

        instance.mint(user, 500);
        assertEq(instance.getMintedSoFar(user), 1000);
        assertEq(instance.balanceOf(user), 1000);
    }

    function testMintExceedsBurnedAllowance() public {
        vm.prank(oracle);
        instance.setBurnedTotalOnPoW(user, 500);

        vm.startPrank(minter);
        instance.mint(user, 500);

        vm.expectRevert(bytes("Mint exceeds burned allowance"));
        instance.mint(user, 1);
    }

    function testNonOracleCantSetBurnedTotal() public {
        vm.startPrank(minter);

        try instance.setBurnedTotalOnPoW(user, 500) {
            revert("Should have failed");
        } catch (bytes memory reason) {
            assertTrue(BytesUtils.startsWith(
                reason, 
                abi.encodePacked(IAccessControl.AccessControlUnauthorizedAccount.selector)));
        }
    }

    function testNonMinterCantMint() public {
        vm.startPrank(oracle);
        instance.setBurnedTotalOnPoW(user, 500);

        try instance.mint(user, 500) {
            revert("Should have failed");
        } catch (bytes memory reason) {
            assertTrue(BytesUtils.startsWith(
                reason, 
                abi.encodePacked(IAccessControl.AccessControlUnauthorizedAccount.selector)));
        }
    }
}
