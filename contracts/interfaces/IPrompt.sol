// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IPrompt {
    function getAIResult(uint256 modelId, string calldata prompt) external view returns (string memory);
}