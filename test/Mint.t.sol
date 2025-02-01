// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "@openzeppelin/contracts/access/IAccessControl.sol";
import {AlphaToken} from "../src/AlphaToken.sol";
import "./utils/BytesUtils.sol";
import "./AbstractTest.sol";

contract MintTest is AbstractTest {
    address user = address(99);

    function testSetBurnedTotal() public {
        vm.prank(oracle);
        alphaMinter.setBurnedTotalOnPoW(user, 1000);
        assertEq(alphaMinter.getBurnedTotalOnPoW(user), 1000);
    }

    function testSetBurnedTotalTwice() public {
        vm.startPrank(oracle);
        alphaMinter.setBurnedTotalOnPoW(user, 1000);
        alphaMinter.setBurnedTotalOnPoW(user, 1001);
        assertEq(alphaMinter.getBurnedTotalOnPoW(user), 1001);
    }

    function testSetBurnedTotalCannotDecrease() public {
        vm.startPrank(oracle);
        alphaMinter.setBurnedTotalOnPoW(user, 1000);
        
        vm.expectRevert(bytes("Cannot reduce burned total"));
        alphaMinter.setBurnedTotalOnPoW(user, 999);
    }

    function testMintHappyCase() public {
        vm.prank(oracle);
        alphaMinter.setBurnedTotalOnPoW(user, 1000);

        vm.startPrank(minter);

        alphaMinter.mint(user, 500);
        assertEq(alphaMinter.getMintedSoFar(user), 500);
        assertEq(alphaToken.balanceOf(user), 500);

        alphaMinter.mint(user, 500);
        assertEq(alphaMinter.getMintedSoFar(user), 1000);
        assertEq(alphaToken.balanceOf(user), 1000);
    }

    function testMintExceedsBurnedAllowance() public {
        vm.prank(oracle);
        alphaMinter.setBurnedTotalOnPoW(user, 500);

        vm.startPrank(minter);
        alphaMinter.mint(user, 500);

        vm.expectRevert(bytes("Mint exceeds burned allowance"));
        alphaMinter.mint(user, 1);
    }

    function testMintZero() public {
        vm.prank(oracle);
        alphaMinter.setBurnedTotalOnPoW(user, 1000);

        vm.startPrank(minter);
        alphaMinter.mint(user, 0);
        assertEq(alphaMinter.getMintedSoFar(user), 0);
        assertEq(alphaToken.balanceOf(user), 0);
    }

    function testMintZero_noBurnedTotalSet() public {
        vm.startPrank(minter);
        alphaMinter.mint(user, 0);
        assertEq(alphaMinter.getMintedSoFar(user), 0);
        assertEq(alphaToken.balanceOf(user), 0);
    }

    function testMintOne_noBurnedTotalSet() public {
        vm.startPrank(minter);
        vm.expectRevert(bytes("Mint exceeds burned allowance"));
        alphaMinter.mint(user, 1);
    }

    function testMintAfterIncreasingBurnedTotal() public {
        vm.prank(oracle);
        alphaMinter.setBurnedTotalOnPoW(user, 500);

        vm.startPrank(minter);
        alphaMinter.mint(user, 500);

        vm.expectRevert(bytes("Mint exceeds burned allowance"));
        alphaMinter.mint(user, 1);
        vm.stopPrank();

        vm.prank(oracle);
        alphaMinter.setBurnedTotalOnPoW(user, 600);

        vm.startPrank(minter);
        alphaMinter.mint(user, 100);
        assertEq(alphaMinter.getMintedSoFar(user), 600);
        assertEq(alphaToken.balanceOf(user), 600);
    }

    function testMultipleUsersMint() public {
        address user1 = address(101);
        address user2 = address(102);

        vm.startPrank(oracle);
        alphaMinter.setBurnedTotalOnPoW(user1, 1000);
        alphaMinter.setBurnedTotalOnPoW(user2, 2000);

        vm.startPrank(minter);
        alphaMinter.mint(user1, 500);
        alphaMinter.mint(user2, 1500);

        vm.expectRevert(bytes("Mint exceeds burned allowance"));
        alphaMinter.mint(user1, 501);

        alphaMinter.mint(user2, 500);

        assertEq(alphaMinter.getMintedSoFar(user1), 500);
        assertEq(alphaToken.balanceOf(user1), 500);
        assertEq(alphaMinter.getMintedSoFar(user2), 2000);
        assertEq(alphaToken.balanceOf(user2), 2000);
    }

    function testMintExactAllowanceMultipleCalls() public {
        vm.prank(oracle);
        alphaMinter.setBurnedTotalOnPoW(user, 1000);

        vm.startPrank(minter);
        alphaMinter.mint(user, 300);
        alphaMinter.mint(user, 300);
        alphaMinter.mint(user, 400);

        assertEq(alphaMinter.getMintedSoFar(user), 1000);
        assertEq(alphaToken.balanceOf(user), 1000);

        vm.expectRevert(bytes("Mint exceeds burned allowance"));
        alphaMinter.mint(user, 1);
    }

    function testMintOverflow() public {
        vm.prank(oracle);
        alphaMinter.setBurnedTotalOnPoW(user, type(uint256).max);

        vm.startPrank(minter);
        alphaMinter.mint(user, type(uint256).max - 1);

        // (mintedSoFar + amount) = (type(uint256).max - 1) + 2, which overflows.
        // Solidity 0.8+ will automatically revert on overflow.
        vm.expectRevert(abi.encodeWithSignature("Panic(uint256)", 0x11));
        alphaMinter.mint(user, 2);
    }

    function testNonOracleCantSetBurnedTotal() public {
        vm.startPrank(minter);

        try alphaMinter.setBurnedTotalOnPoW(user, 500) {
            revert("Should have failed");
        } catch (bytes memory reason) {
            assertTrue(BytesUtils.startsWith(
                reason, 
                abi.encodePacked(IAccessControl.AccessControlUnauthorizedAccount.selector)));
        }
    }

    function testNonMinterCantMint() public {
        vm.startPrank(oracle);
        alphaMinter.setBurnedTotalOnPoW(user, 500);

        try alphaMinter.mint(user, 500) {
            revert("Should have failed");
        } catch (bytes memory reason) {
            assertTrue(BytesUtils.startsWith(
                reason, 
                abi.encodePacked(IAccessControl.AccessControlUnauthorizedAccount.selector)));
        }
    }
}
