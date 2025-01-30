// SPDX-License-Identifier: Unlicensed
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Alpha} from "./Alpha.sol";

contract AlphaMinter is AccessControl {
    bytes32 public constant ORACLE_ROLE = keccak256("ORACLE_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    mapping(address => uint256) private burnedTotalsOnPoW;

    mapping(address => uint256) private mintedSoFar;

    Alpha private alphaToken;

    constructor(Alpha _alphaToken, address _defaultAdmin, address _oracle, address _minter) {
        alphaToken = _alphaToken;

        _grantRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);
        _grantRole(ORACLE_ROLE, _oracle);
        _grantRole(MINTER_ROLE, _minter);
    }

    // The newValue parameter must be in accordance with the decimals value of the current smart contract.
    function setBurnedTotalOnPoW(address user, uint256 newValue) public onlyRole(ORACLE_ROLE) {
        require (newValue >= burnedTotalsOnPoW[user], "Cannot reduce burned total");
        burnedTotalsOnPoW[user] = newValue;
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        require (mintedSoFar[to] + amount <= burnedTotalsOnPoW[to], "Mint exceeds burned allowance");

        mintedSoFar[to] += amount;

        alphaToken.mint(to, amount);
    }

    function getBurnedTotalOnPoW(address user) external view returns (uint256) {
        return burnedTotalsOnPoW[user];
    }

    function getMintedSoFar(address user) external view returns (uint256) {
        return mintedSoFar[user];
    }
}
