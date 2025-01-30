// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Alpha} from "../src/Alpha.sol";

/// @custom:oz-upgrades-from Alpha
contract MockAlphaV2 is Alpha {
    function initialize() public reinitializer(2) {
        super.initialize(msg.sender, msg.sender, msg.sender);
    }

    function name() public pure override returns (string memory) {
        return "AlphaV2";
    }
}