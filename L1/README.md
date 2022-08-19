# Stake Contract

## Prerequisites

- [Setup hardhat](https://hardhat.org/hardhat-runner/docs/getting-started#installation)

## Compile and Deploy

1. Check whether the compilation is successful

```
npx hardhat compile
```

2. Create `L1/.env` file with the following contents:
   Alchemy can be used to connect to the network (Any JSON-RPC URL can be used instead)

```
ALCHEMY_URL=<Alchemy key>
PRIVATE_KEY=<Ethereum Wallet private key>
```

3. In `L1/scripts/deploy.js` pass the address of Starknet contract (L2) as the second argument of constructor

4. Deploy the contract

```
npx hardhat run scripts/deploy.js --network goerli
```
