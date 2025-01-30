// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AlphaToken} from "../src/AlphaToken.sol";

/// @custom:oz-upgrades-from AlphaToken
contract MockAlphaV2 is AlphaToken {
    function initialize() public reinitializer(2) {
        super.initialize(msg.sender, msg.sender, msg.sender);
    }

    function name() public pure override returns (string memory) {
        return "AlphaV2";
    }
}