%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_le, assert_not_zero
from starkware.starknet.common.messages import send_message_to_l1
from starkware.starknet.common.syscalls import get_caller_address

#############
# Constants #
#############
const MESSAGE_WITHDRAW = 1

###########
# Storage #
###########

# Stores admin address
@storage_var
func admin_address() -> (address : felt):
end

# Mapping to store user's L1 address and balance
@storage_var
func user_balance(user_l1_address : felt, user_l2_address : felt) -> (balance : felt):
end

# Stores Stake L1 contract's address
@storage_var
func stake_l1_address() -> (address : felt):
end

###############
# Constructor #
###############

# @notice Constructor of the smart contract
# @param admin_address - Admin address of this smart contract
@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    admin_address_ : felt
):
    # Validate arguments
    with_attr error_message("Admin address should not be 0"):
        assert_not_zero(admin_address_)
    end

    # Initialize admin
    admin_address.write(admin_address_)

    return ()
end

##################
# View functions #
##################

# @notice Get balance of a user
# @param user_l1_address_ - User's l1 address
# @return balance - Balance of the user
@view
func get_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    user_l1_address_ : felt, user_l2_address_ : felt
) -> (balance : felt):
    let (balance) = user_balance.read(user_l1_address_, user_l2_address_)
    return (balance)
end

# @notice Get Stake l1 contract address
# @return l1_address - Address of Stake l1 contract
@view
func get_l1_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    l1_address : felt
):
    let (l1_address) = stake_l1_address.read()
    return (l1_address)
end

##############
# L1 Handler #
##############

# @notice Function to handle deposit from Stake L1 contract
# @param from_address_ - The address from where deposit function is called
# @param user - User's l1 address
# @param amount - The Amount of funds that user wants to deposit
@l1_handler
func deposit{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    from_address : felt, user_l1_address_ : felt, user_l2_address_ : felt, amount_ : felt
):
    let (l1_address) = stake_l1_address.read()
    with_attr error_message("Message must be sent from authorized Stake L1 address"):
        assert from_address = l1_address
    end

    user_balance.write(
        user_l1_address=user_l1_address_, user_l2_address=user_l2_address_, value=amount_
    )

    return ()
end

######################
# External functions #
######################

# @notice Set address of Stake L1 contract by admin
# @param stake_l1_address_ - address of Stake L1 contract
@external
func set_stake_l1_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    stake_l1_address_ : felt
):
    # Auth check
    let (caller) = get_caller_address()
    let (admin) = admin_address.read()
    with_attr error_message("Only admin can call this function"):
        assert caller = admin
    end

    stake_l1_address.write(stake_l1_address_)

    return ()
end

# @notice Withdraw amount from this contract
# @param user_l1_address_ - l1 address of user
# @param amount_ - amount to be withdrawn
@external
func withdraw{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    user_l1_address_ : felt, amount_ : felt
):
    let (caller) = get_caller_address()
    let (balance) = user_balance.read(user_l1_address_, caller)

    with_attr error_message(
            "Balance is less than the withdrawal amount requested for this combination"):
        assert_le(amount_, balance)
    end

    user_balance.write(
        user_l1_address=user_l1_address_, user_l2_address=caller, value=balance - amount_
    )

    let (l1_address) = stake_l1_address.read()

    # Send the withdrawal message.
    let (message_payload : felt*) = alloc()
    assert message_payload[0] = MESSAGE_WITHDRAW
    assert message_payload[1] = user_l1_address_
    assert message_payload[2] = amount_

    # Send Message to L1
    send_message_to_l1(to_address=l1_address, payload_size=3, payload=message_payload)

    return ()
end
