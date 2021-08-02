# Stake and Reward Contracts
The repository consists of contracts to allow staking and minting of rewards for a given holders of a custom BEP20 token. This also calculates a custom APY for each stake which is then
calculated for every staking account. 

# Overview
Decentralized Finance has paved a new innovation in building an open environment for attaining and earning wealth through cryptocurrencies. Smart Contract execution in a distributed environment has made it possible to create several logical and conditional schematics on how to manage crypto assets and calculate reward and percentage based on defined financial instruments defined by the product owners.

# Related Components
stake-reward-ui - the main user interface of the stake-reward-contracts. A live version can be tested [here](https://test-edipi.wealthid.finance/)

# Run The Code
The repository requires Truffle v5.0.3 to run

## For Deploying the contracts

```
truffle migrate --network testnet
```

## For Compiling
```
truffle compile
```
## Plugins

We've used the following plugins

- Truffle
- Ganache
- Solhint

# Integration
Interested in building your own stake and reward products using EVM based contracts, Reach out at info@proofsys.io for implementation and integration inquiries.