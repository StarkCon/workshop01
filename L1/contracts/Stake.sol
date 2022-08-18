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

    /// @dev function to deposit ETH to Stake contract
    function depositEthToL1()
        external
        payable
    {
        require(msg.value > 0, "Deposit failed: no value provided");

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
