// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {Alpha} from "../src/Alpha.sol";
import {AlphaMinter} from "../src/AlphaMinter.sol";

abstract contract AbstractTest is Test {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    address public defaultAdmin;
    address public pauser;
    address public oracle;
    address public minter;
    address public upgrader;

    Alpha public alphaToken;
    AlphaMinter public alphaMinter;

    function setUp() public virtual {
        defaultAdmin = vm.addr(1);
        pauser = vm.addr(2);
        oracle = vm.addr(3);
        minter = vm.addr(4);
        upgrader = vm.addr(5);

        address proxy = Upgrades.deployUUPSProxy(
            "Alpha.sol",
            abi.encodeCall(
                Alpha.initialize,
                (defaultAdmin, pauser, upgrader)
            )
        );
        alphaToken = Alpha(proxy);

        alphaMinter = new AlphaMinter(alphaToken, defaultAdmin, oracle, minter);

        vm.startPrank(defaultAdmin);
        alphaToken.grantRole(alphaToken.MINTER_ROLE(), address(alphaMinter));
        vm.stopPrank();
    }

}
