// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {AlphaToken} from "../src/AlphaToken.sol";
import "./AbstractTest.sol";
import "./MockAlphaV2.sol";

contract UpgradingTest is AbstractTest {
    function testUpgrading() public {
        assertEq(alphaToken.name(), "Alpha");

        vm.startPrank(upgrader);
        Upgrades.upgradeProxy (address(alphaToken), "MockAlphaV2.sol", "");

        assertEq(alphaToken.name(), "AlphaV2");
    }
}
