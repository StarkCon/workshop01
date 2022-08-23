// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IStarknetCore.sol";

contract Stake {

    /////////////////
    /// Constants ///
    /////////////////

    // The selector of the "deposit" l1_handler.
    uint256 constant DEPOSIT_SELECTOR = 352040181584456735608515580760888541466059565068553383579463728554843487745;

    // Message withdrawal index
    uint256 constant WITHDRAWAL_INDEX = 1;

    ///////////////
    /// Storage ///
    ///////////////

    /// The StarkNet core contract
    IStarknetCore immutable public starknetCore;

    /// L2 Stake Contract address
    uint256 public stakeL2Address;

    ///////////////////
    /// Constructor ///
    ///////////////////

    /// @param starknetCore_ StarknetCore contract address used for L1-to-L2 messaging
    /// @param stakeL2Address_ L2 Stake Contract address
    constructor(
        IStarknetCore starknetCore_,
        uint256 stakeL2Address_
    ) {
        require(address(starknetCore_) != address(0));

        starknetCore = starknetCore_;
        stakeL2Address = stakeL2Address_;
    }

    //////////////////////////
    /// External functions ///
    //////////////////////////

    /// @dev function to deposit ETH to Stake contract
    function stake()
        external
        payable
    {

        uint256 senderAsUint256 = uint256(uint160(msg.sender));

        uint256[] memory payload = new uint256[](2);
        payload[0] = senderAsUint256;
        payload[1] = msg.value;

        starknetCore.sendMessageToL2(
            stakeL2Address,
            DEPOSIT_SELECTOR,
            payload
        );
    }

    /// @dev function to withdraw funds from an L2 Account contract
    /// @param amount_ - The amount of tokens to be withdrawn
    function withdraw(
        uint256 amount_
    ) external {
        uint256 senderAsUint256 = uint256(uint160(msg.sender));

        uint256[] memory payload = new uint256[](3);
        payload[0] = WITHDRAWAL_INDEX;
        payload[1] = senderAsUint256;
        payload[2] = amount_;

        // Consume call will revert if no matching message exists
        starknetCore.consumeMessageFromL2(
            stakeL2Address,
            payload
        );

        payable(msg.sender).transfer(amount_);
    }
}
