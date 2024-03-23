const hre = require("hardhat");
const addressJson = require("../ignition/deployments/chain-11155111/deployed_addresses.json");

const contractAddress = addressJson["GrokVsLlamaModule#GrokVsLlama"];
const samplePrompts = [
    "Give me 10 date-night ideas for me and my partner but include ideas that we can do in the house, outdoors and within a 10-mile radius.", //1194
    "Create a bulleted list of organic supplements that boost metabolism.", //1261
    "hello, how old are you?" //1263
]

async function main() {
    contract = await hre.ethers.getContractAt("GrokVsLlama", contractAddress);
    
    let tx = await contract.testCallback(0, "0x20594553", "0x");

    let receipt = await tx.wait();
    console.log(receipt);

    const gasLimit = receipt.gasUsed * BigInt(10);
    tx = await contract.setCallbackGasLimit(gasLimit);

    receipt = await tx.wait();
    console.log(receipt);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
