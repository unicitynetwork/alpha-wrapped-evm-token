// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {Alpha} from "../src/Alpha.sol";
import "./AbstractTest.sol";
import "./MockAlphaV2.sol";

contract UpgradingTest is AbstractTest {
    function testUpgrading() public {
        assertEq(instance.name(), "Alpha");

        vm.startPrank(upgrader);
        Upgrades.upgradeProxy (address(instance), "MockAlphaV2.sol", "");

        assertEq(instance.name(), "AlphaV2");
    }
}
