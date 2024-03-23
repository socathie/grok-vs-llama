// SampleContract.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

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

    address immutable owner;
    IPrompt immutable prompt;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    // requestId => AIOracleRequest
    mapping(uint256 => AIOracleRequest) public requests;

    uint256 public constant MODEL_ID = 11; // llama    
    uint64 public callbackGasLimit = 5_000_000; // llama

    /// @notice Initialize the contract, binding it to a specified AIOracle. Bounty is msg.value.
    constructor(IAIOracle _aiOracle, address _prompt) AIOracleCallbackReceiver(_aiOracle) payable {
        owner = msg.sender;
        prompt = IPrompt(_prompt);
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
        if (keccak256(output) == keccak256("NO")) {
            (bool success, ) = request.sender.call{value: address(this).balance}("");
            require(success, "Transfer failed.");
        }
    }

    function estimateFee() public view returns (uint256) {
        return aiOracle.estimateFee(MODEL_ID, callbackGasLimit);
    }

    function requestBattle(uint256 grokRequestId) payable external {
        IPrompt.AIOracleRequest memory grokRequest = prompt.requests(grokRequestId);
        
        // !: sender should match, but commented out for testing
        // require(grokRequest.sender == msg.sender, "Not your request");
        require(grokRequest.modelId == 9, "Not a Grok request");

        bytes memory input = abi.encodePacked(PROMPT_PREFIX, grokRequest.input, " Response: ", grokRequest.output);
        
        // we do not need to set the callbackData in this example
        uint256 requestId = aiOracle.requestCallback{value: msg.value}(
            MODEL_ID, input, address(this), callbackGasLimit, ""
        );
        AIOracleRequest storage request = requests[requestId];
        request.input = input;
        request.sender = msg.sender;
        emit promptRequest(requestId, msg.sender, string(input));
    }

    receive() external payable {}
}
