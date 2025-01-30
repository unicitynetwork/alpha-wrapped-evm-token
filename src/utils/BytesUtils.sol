// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

library BytesUtils {
    function slice(bytes memory b, uint256 from, uint256 to) internal pure returns (bytes memory result) {
        require(from <= to, "FROM_LESS_THAN_TO_REQUIRED");
        require(to <= b.length, "TO_LESS_THAN_LENGTH_REQUIRED");

        result = new bytes(to - from);
        for (uint i = 0; i < result.length; i++) {
            result[i] = b[from + i];
        }
    }

    function substring(bytes memory b, uint offset, uint length) internal pure returns(bytes memory) {
        return slice(b, offset, offset + length);
    }

    function startsWith(bytes memory b, bytes memory prefix) internal pure returns(bool) {
        return 
            prefix.length <= b.length &&
            sha256(BytesUtils.substring(b, 0, prefix.length)) == sha256(prefix);
    }
 }
