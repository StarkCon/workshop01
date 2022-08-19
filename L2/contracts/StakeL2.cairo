%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero
from starkware.starknet.common.syscalls import get_caller_address

###########
# Storage #
###########

# Stores admin address
@storage_var
func admin_address() -> (address : felt):
end

# Mapping to store user's L1 address and balance
@storage_var
func user_balance(user_l1_address : felt) -> (balance : felt):
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
    user_l1_address_ : felt
) -> (balance : felt):
    let (balance : felt) = user_balance.read(user_l1_address_)
    return (balance)
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
    with_attr error_message("Message must be sent from authorized Stake L1 address"):
        assert from_address = l1_address
    end

    user_balance.write(user_l1_address=user_l1_address_, value=amount_)

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
