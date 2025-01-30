// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "@openzeppelin/contracts/access/IAccessControl.sol";
import {Alpha} from "../src/Alpha.sol";
import "../src/utils/BytesUtils.sol";
import "./AbstractTest.sol";

contract Erc20StandardFunctionsTest is AbstractTest {
    uint256 userPrivateKey = 0x123456; 

    address user = vm.addr(userPrivateKey);
    address recipient = address(100);

    function setUp() public override virtual {
        super.setUp();

        vm.prank(oracle);
        alphaMinter.setBurnedTotalOnPoW(user, 500);
        vm.prank(minter);
        alphaMinter.mint(user, 500);
    }

    function testTransfer() public {
        vm.startPrank(user);

        vm.expectEmit(true, true, true, true);
        emit Transfer(user, recipient, 200);

        bool success = alphaToken.transfer(recipient, 200);
        assertTrue(success);
        assertEq(alphaToken.balanceOf(user), 300);
        assertEq(alphaToken.balanceOf(recipient), 200);
    }

    function testERC20ApproveAndTransferFrom() public {
        vm.startPrank(user);

        vm.expectEmit(true, true, true, true);
        emit Approval(user, minter, 300);
        bool approved = alphaToken.approve(minter, 300);
        assertTrue(approved);

        vm.startPrank(minter);
        vm.expectEmit(true, true, true, true);
        emit Transfer(user, recipient, 200);

        bool success = alphaToken.transferFrom(user, recipient, 200);
        assertTrue(success);

        assertEq(alphaToken.balanceOf(user), 300);
        assertEq(alphaToken.balanceOf(recipient), 200);
        assertEq(alphaToken.allowance(user, minter), 100);
    }

    function testPermit() public {
        uint256 nonceBefore = alphaToken.nonces(user);
        uint256 deadline = block.timestamp + 1 hours;

        bytes32 digest = _buildPermitDigest(
            user,
            minter,
            600,
            nonceBefore,
            deadline
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, digest);

        vm.expectEmit(true, true, true, true);
        emit Approval(user, minter, 600);

        alphaToken.permit(user, minter, 600, deadline, v, r, s);

        uint256 nonceAfter = alphaToken.nonces(user);
        assertEq(nonceAfter, nonceBefore + 1);

        uint256 newAllowance = alphaToken.allowance(user, minter);
        assertEq(newAllowance, 600);
    }

    function _buildPermitDigest(
        address owner,
        address spender,
        uint256 value,
        uint256 nonce,
        uint256 deadline
    ) internal view returns (bytes32) {
        bytes32 domainSeparator = alphaToken.DOMAIN_SEPARATOR();

        bytes32 structHash = keccak256(
            abi.encode(
                keccak256(
                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                ),
                owner,
                spender,
                value,
                nonce,
                deadline
            )
        );

        return keccak256(
            abi.encodePacked("\x19\x01", domainSeparator, structHash)
        );
    }
}