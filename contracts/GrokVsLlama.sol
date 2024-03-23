// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./interfaces/IPrompt.sol";
import "./interfaces/IAIOracle.sol";
import "./AIOracleCallbackReceiver.sol";

contract GrokVsLlama is AIOracleCallbackReceiver {

    bytes public constant PROMPT_PREFIX = "Only answer \"YES\" or \"NO\". Do the following prompt and response correspond to each other? Prompt: ";

    event promptsUpdated(
        uint256 requestId,
        string input,
        string output,
        bytes callbackData
    );

    event promptRequest(
        uint256 requestId,
        address sender,
        string prompt
    );
    
    struct AIOracleRequest {
        address sender;
        bytes input;
        bytes output;
    }

    address public immutable owner;
    address public immutable prompt;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    // requestId => AIOracleRequest
    mapping(uint256 => AIOracleRequest) public requests;

    bytes public constant NO = hex"204e4f";
    uint256 public constant MODEL_ID = 11; // llama    
    uint64 public callbackGasLimit = 5_000_000; // llama

    /// @notice Initialize the contract, binding it to a specified AIOracle. Bounty is msg.value.
    constructor(IAIOracle _aiOracle, address _prompt) AIOracleCallbackReceiver(_aiOracle) payable {
        owner = msg.sender;
        prompt = _prompt;
    }

    function setCallbackGasLimit(uint64 gasLimit) external onlyOwner {
        callbackGasLimit = gasLimit;
    }

    // uint256: modelID => (string: prompt => string: output)
    mapping(string => string) public prompts;

    // the callback function, only the AI Oracle can call this function
    function aiOracleCallback(uint256 requestId, bytes calldata output, bytes calldata callbackData) external override onlyAIOracleCallback() {
        // since we do not set the callbackData in this example, the callbackData should be empty
        AIOracleRequest storage request = requests[requestId];
        require(request.sender != address(0), "request not exists");
        request.output = output;
        emit promptsUpdated(requestId, string(request.input), string(output), callbackData);
        if (keccak256(output) == keccak256(NO)) { // No
            (bool success, ) = request.sender.call{value: address(this).balance}("");
            require(success, "Transfer failed.");
        }
    }

    function estimateFee() public view returns (uint256) {
        return aiOracle.estimateFee(MODEL_ID, callbackGasLimit);
    }

    function requestBattle(string memory input) payable external {
        string memory output = IPrompt(prompt).getAIResult(9, input); // grok

        // !: should check prompt sender is the same as msg.sender, but struct in prompt is too big to read

        bytes memory _prompt = abi.encodePacked(PROMPT_PREFIX, input, " Response: ", output);
        
        // // we do not need to set the callbackData in this example
        uint256 requestId = aiOracle.requestCallback{value: msg.value}(
            MODEL_ID, _prompt, address(this), callbackGasLimit, ""
        );
        AIOracleRequest storage request = requests[requestId];
        request.input = _prompt;
        request.sender = msg.sender;
        emit promptRequest(requestId, msg.sender, string(_prompt));
    }

    function testCallback(uint256 requestId, bytes calldata output, bytes calldata callbackData) external onlyOwner {
        // since we do not set the callbackData in this example, the callbackData should be empty
        AIOracleRequest storage request = requests[requestId];
        require(requestId == 0, "requestId must be 0");
        request.output = output;
        emit promptsUpdated(requestId, string("test"), string(output), callbackData);
        if (keccak256(output) == keccak256(NO)) { // No
            (bool success, ) = owner.call{value: 0}("");
            require(success, "Transfer failed.");
        }
    }

    receive() external payable {}
}
