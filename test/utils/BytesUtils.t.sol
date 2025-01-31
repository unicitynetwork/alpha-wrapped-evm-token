// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import "./BytesUtils.sol";

contract BytesUtilsTest is Test {
    function setUp() public {
    }
    
    function testSlice() public pure {
        assertEq(
            BytesUtils.slice(hex"000102030405", 1, 5),
            hex"01020304"
        );
    }
    
    function testSubstring() public pure {
        assertEq(
            BytesUtils.substring(hex"000102030405", 1, 4),
            hex"01020304"
        );
    }

    function testStartsWith() public pure {
        assertEq(BytesUtils.startsWith(hex"", hex""), true);
        assertEq(BytesUtils.startsWith(hex"00", hex""), true);
        assertEq(BytesUtils.startsWith(hex"", hex"00"), false);

        assertEq(BytesUtils.startsWith(bytes("http"), bytes("xx")), false);
        assertEq(BytesUtils.startsWith(bytes("http"), bytes("ht")), true);
    }
}
