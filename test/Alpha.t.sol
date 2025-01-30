// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {Alpha} from "../src/Alpha.sol";
import "./AbstractTest.sol";

contract AlphaTest is AbstractTest {
    function testMetadata() public view {
        assertEq(instance.name(), "Alpha");
        assertEq(instance.symbol(), "ALPHA");
        assertEq(instance.decimals(), 18);
    }
}
