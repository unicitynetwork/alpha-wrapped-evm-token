// SPDX-License-Identifier: Unlicensed
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {AlphaToken} from "./AlphaToken.sol";

/**
 * @dev Controls the minting of Alpha tokens based on proof-of-burn data from a PoW chain.
 *      Utilizes AccessControl with two main roles:
 *
 *      - ORACLE_ROLE: Updates the recorded burn totals from the PoW chain.
 *      - MINTER_ROLE: Mints new tokens; the contract ensures that the amount minted for each 
 *                     address never exceeds its recorded burn total.
 *
 * References an external Alpha token contract (AlphaToken.sol). Actual ERC20 token issuance occurs
 * when the `mint` function is invoked.
 */
contract AlphaMinter is AccessControl {
    bytes32 public constant ORACLE_ROLE = keccak256("ORACLE_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    mapping(address => uint256) private burnedTotalsOnPoW;

    mapping(address => uint256) private mintedSoFar;

    AlphaToken private alphaToken;

    constructor(AlphaToken _alphaToken, address _defaultAdmin, address _oracle, address _minter) {
        alphaToken = _alphaToken;

        _grantRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);
        _grantRole(ORACLE_ROLE, _oracle);
        _grantRole(MINTER_ROLE, _minter);
    }

    /**
     * @dev Updates the total amount burned on the PoW chain for a given EVM address
     *      on the current chain.
     *
     * @param user The address of the user whose burned total is being updated.
     * @param newValue The new total burned amount. Its decimals format must match the 
     *                 decimals of the target ERC20 contract, as no conversion is done 
     *                 by this function. The value cannot be reduced over time: it must 
     * .               be greater than or equal to the current burned total for the user.
     */
    function setBurnedTotalOnPoW(address user, uint256 newValue) public onlyRole(ORACLE_ROLE) {
        require (newValue >= burnedTotalsOnPoW[user], "Cannot reduce burned total");
        burnedTotalsOnPoW[user] = newValue;
    }

    /**
     * @dev Mints the underlying ERC20 tokens for the user.
     * Amount minted cannot exceed the total amount user has burned on PoW chain
     * minus what they have already minted.
     */    
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
