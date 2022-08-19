# Workshop Application

This is a basic dApp in Starknet which can communicate with Ethereum, from where it inherits its security.
The functionalities are as follows:

- A user can deposit ETH to Stake contract (L1). This information will be communicated to Starknet contract (L2), which will store it.
- In Starknet contract there is a function to take fee from any user, which will reduce the user's balance.
- Finally user can initiate withdraw from Starknet contract, which will then be communicated to Stake Contract (L1).
- Once the user consumes this message in L1, corresponding amount of ETH will be transferred back to the user.

# How to setup and test

Since there are 2 separate contracts on Ethereum and Starknet, both setup need to be done.

- First follow the README file inside L2 folder
- Later follow the README file inside L1 folder
