pragma solidity 0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IStarknetCore.sol";

contract Stake is Ownable {

    /////////////////
    /// Constants ///
    /////////////////

    // Used to check l2 address range
    uint256 constant FIELD_PRIME = 0x800000000000011000000000000000000000000000000000000000000000001;

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
        require(isValidFelt(stakeL2Address_));

        starknetCore = starknetCore_;
        stakeL2Address = stakeL2Address_;
    }

    //////////////////////////
    /// External functions ///
    //////////////////////////

    /// @dev function to deposit ETH to Stake contract
    /// @param userL2Address_ - User's L2 Account address
    function depositEthToL1(uint256 userL2Address_)
        external
        payable
    {
        require(msg.value > 0, "Deposit failed: no value provided");
        require(isValidFelt(userL2Address_));

        uint256 senderAsUint256 = uint256(uint160(msg.sender));

        uint256[] memory payload = new uint256[](3);
        payload[0] = senderAsUint256;
        payload[1] = userL2Address_;
        payload[2] = msg.value;

        starknetCore.sendMessageToL2(
            stakeL2Address,
            DEPOSIT_SELECTOR,
            payload
        );
    }

    /// @dev function to withdraw funds from an L2 Account contract
    /// @param amount_ - The amount of tokens to be withdrawn
    function withdrawEth(
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

    /////////////////////////
    /// Private functions ///
    /////////////////////////

    /// @dev Checks if value is a valid Cairo felt
    /// @param value_ - Value to be checked
    /// @return isValid - Validation result
    function isValidFelt(uint256 value_) private pure returns (bool isValid) {
        return value_ != 0 && value_ < FIELD_PRIME;
    }
}
