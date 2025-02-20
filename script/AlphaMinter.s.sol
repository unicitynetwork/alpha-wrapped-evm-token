// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {AlphaToken} from "src/AlphaToken.sol";
import {AlphaMinter} from "src/AlphaMinter.sol";

contract AlphaMinterScript is Script {
    function setUp() public pure {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        require(deployerPrivateKey != 0, "PRIVATE_KEY is not set");

        address alphaTokenAddress = vm.envAddress("ALPHA_TOKEN");
        require(alphaTokenAddress != address(0), "ALPHA_TOKEN is not set");

        address defaultAdmin = vm.envAddress("DEFAULT_ADMIN");
        require(defaultAdmin != address(0), "DEFAULT_ADMIN is not set");

        address oracle = vm.envAddress("ORACLE");
        require(oracle != address(0), "ORACLE is not set");

        address minter = vm.envAddress("MINTER");
        require(minter != address(0), "MINTER is not set");

        console.log("Deployer: %s", vm.addr(deployerPrivateKey));
        console.log("AlphaToken address: %s", alphaTokenAddress);
        console.log("Default admin: %s", defaultAdmin);
        console.log("Oracle: %s", oracle);
        console.log("Minter: %s", minter);

        vm.startBroadcast(deployerPrivateKey);

        AlphaMinter minterInstance = new AlphaMinter(
            AlphaToken(alphaTokenAddress),
            defaultAdmin,
            oracle,
            minter
        );

        console.log("AlphaMinter deployed to %s", address(minterInstance));
        vm.stopBroadcast();
    }
}
