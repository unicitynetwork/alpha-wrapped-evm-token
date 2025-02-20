// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {AlphaToken} from "src/AlphaToken.sol";

contract GrantMinterRoleScript is Script {
    function setUp() public pure {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        require(deployerPrivateKey != 0, "PRIVATE_KEY is not set");

        address tokenAddress = vm.envAddress("ALPHA_TOKEN");
        require(tokenAddress != address(0), "ALPHA_TOKEN is not set");

        address newMinter = vm.envAddress("ALPHA_MINTER");
        require(newMinter != address(0), "ALPHA_MINTER is not set");

        bytes32 minterRole = AlphaToken(tokenAddress).MINTER_ROLE();

        vm.startBroadcast(deployerPrivateKey);

        AlphaToken(tokenAddress).grantRole(minterRole, newMinter);

        vm.stopBroadcast();
    }
}