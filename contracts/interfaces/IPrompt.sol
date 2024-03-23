// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IPrompt {
    struct AIOracleRequest {
        address sender;
        uint256 modelId;
        bytes input;
        bytes output;
    }

    function requests(uint256) external view returns (AIOracleRequest memory);
}