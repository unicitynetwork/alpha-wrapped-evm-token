// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {AlphaToken} from "src/AlphaToken.sol";

contract AlphaTokenScript is Script {
    function setUp() public pure {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        require(deployerPrivateKey != 0, "PRIVATE_KEY is not set");

        address defaultAdmin = vm.envAddress("DEFAULT_ADMIN");
        require(defaultAdmin != address(0), "DEFAULT_ADMIN is not set");

        address pauser = vm.envAddress("PAUSER");
        require(pauser != address(0), "PAUSER is not set");

        address upgrader = vm.envAddress("UPGRADER");
        require(upgrader != address(0), "UPGRADER is not set");

        console.log("Deployer's public key is: %s", vm.addr(deployerPrivateKey));
        console.log("Default admin: %s", defaultAdmin);
        console.log("Pauser: %s", pauser);
        console.log("Upgrader: %s", upgrader);

        vm.startBroadcast(deployerPrivateKey);
        address proxy = Upgrades.deployUUPSProxy(
            "AlphaToken.sol",
            abi.encodeCall(
                AlphaToken.initialize,
                (defaultAdmin, pauser, upgrader)
            )
        );
        AlphaToken instance = AlphaToken(proxy);
        console.log("Proxy deployed to %s", address(instance));
        vm.stopBroadcast();

        console.log();
        console.log("Do not forget to set the minter!");
    }
}