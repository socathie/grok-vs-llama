# Grok vs Llama

![](cover.png)

Grok, a 314B parameter LLM by X, was open-sourced recently. Grok is considered the pinnacle of open source LLM.

However, the original Grok without prompt engineering was often seen as having too much of its own "personality" and often answering the wrong questions. Or, a state called "Glitch" (repeating the same phrase like "Grok Grok Grok Grok" over and over).

In our project, we implemented Grok vs LlaMA2, where LlaMA2, another open source LLM, monitors whether Grok is in a Glitch state, and if so, the user who initiated the AI request is rewarded with a bounty for finding Grok's "weakness".

In our case, all inference calculations for Grok and LlaMA2 models, as well as the bounty sending process, are onchain, ensuring end-to-end verifiability.

## How It’s Made

We utilized ORA's Onchain AI Oracle (https://docs.ora.io/doc/cle/ai-oracle) to get onchain Grok and LlaMA2.

## Usage

```shell
npx hardhat ignition deploy ignition/modules/GrokVsLlama.js --network sepolia --verify
npx hardhat run scripts/testOnSepolia.js --network sepolia
```

## Future
This project provides a foundation for AI to monitor each other.

In the future network of AI agents, we can realize the mutual monitoring of AI in this way, so as to reduce the intentional or unintentional evil behavior of AI. At the same time, this approach can realize a completely autonomous AI network system without human intervention.