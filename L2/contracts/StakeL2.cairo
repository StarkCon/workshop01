%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_le
from starkware.starknet.common.messages import send_message_to_l1

#############
# Constants #
#############

const MESSAGE_WITHDRAW = 1
const FEE = 100000000000000

###########
# Storage #
###########

# Mapping to store user's L1 address and balance
@storage_var
func user_balance(user_l1_address : felt) -> (balance : felt):
end

# Stores Stake L1 contract's address
@storage_var
func stake_l1_address() -> (address : felt):
end

##################
# View functions #
##################

# @notice Get balance of a user
# @param user_l1_address_ - User's l1 address
# @return balance - Balance of the user
@view
func get_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    user_l1_address_ : felt
) -> (balance : felt):
    let (balance) = user_balance.read(user_l1_address_)
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
    from_address : felt, user_l1_address_ : felt, amount_ : felt
):
    let (l1_address) = stake_l1_address.read()
    assert from_address = l1_address

    let (current_balance) = user_balance.read(user_l1_address_)
    user_balance.write(user_l1_address=user_l1_address_, value=current_balance + amount_)

    return ()
end

######################
# External functions #
######################

# @notice Set address of Stake L1 contract
# @param stake_l1_address_ - address of Stake L1 contract
@external
func set_stake_l1_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    stake_l1_address_ : felt
):
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
    let (balance) = user_balance.read(user_l1_address_)

    assert_le(amount_, balance)

    user_balance.write(user_l1_address=user_l1_address_, value=balance - amount_)

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

# @notice Reduce a constant amount from user's balance
# @param user_l1_address_ - l1 address of user
@external
func take_fee{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    user_l1_address_ : felt
):
    let (balance) = user_balance.read(user_l1_address_)

    assert_le(FEE, balance)

    user_balance.write(user_l1_address=user_l1_address_, value=balance - FEE)

    return ()
end
