# STARKNET

## Prerequisites

- [Setup the environment for starknet and cairo](https://cairo-lang.org/docs/quickstart.html)
- [Setup Nile framework](https://github.com/OpenZeppelin/nile)

## Compile and Deploy

1. Compile the contract

```
nile compile
```

2. Deploy the contract

```
export STARKNET_NETWORK=alpha-goerli
starknet deploy --contract artifacts/StakeL2.json --no_wallet
```

## Finish the setup for this contract

3. Deploy L1 contract before doing the next step here (Follow README file inside L1 folder)

4. Install Argent/Braavos wallet for Starknet in your browser

5. Go to [Voyager](https://goerli.voyager.online/) and search for the contract address you got in step 2.

6. Inside 'Write Contract' tab, take 'set_stake_l1_address' function.

7. Provide Stake contract address (L1) and transact. Now the L1 address is saved in L2 contract.

## Starknet Documentation

Read more about Starknet [here](https://cairo-lang.org/docs/hello_starknet/index.html)
