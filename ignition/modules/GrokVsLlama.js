const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("GrokVsLlamaModule", (m) => {

  const grokVsLlama = m.contract("GrokVsLlama", ["0x0A0f4321214BB6C7811dD8a71cF587bdaF03f0A0", "0x64BF816c3b90861a489A8eDf3FEA277cE1Fa0E82"], {
    value: ethers.parseEther("0.01"),
  });

  return { grokVsLlama };
});
