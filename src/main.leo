program wright_lottery.aleo {
    // Create user structure
    struct Participant {
        participant_address: address,
        amount: u64,
    }

    mapping participants: address => Participant;

    record lottery_state {
        owner: address,
        total_amount: u64,
        participants_amount: u32,
    }

    transition initialize_lottery() -> lottery_state {
        return lottery_state{
            owner: self.caller,
            total_amount: 0u64,
            participants_amount: 0u32,
        };
    }

    // Function to buy a ticket
    transition buy_ticket(participantAddress: address, amount: u64, old_lottery_state: lottery_state) -> lottery_state {
        assert(amount > 0u64);
        
        // Calculate the new total amount and increment the participants count
        let new_total_amount: u64 = old_lottery_state.total_amount + amount;
        let new_participants_amount: u32 = old_lottery_state.participants_amount + 1u32;
        
        // Create a new lottery state with updated values
        let new_lottery_state: lottery_state = lottery_state{
            owner: old_lottery_state.owner,
            total_amount: new_total_amount,
            participants_amount: new_participants_amount,
        };
        
        return new_lottery_state then finalize(participantAddress, amount);
    }
    finalize buy_ticket (participantAddress: address, amount: u64) {
        // Update the participant mapping
        Mapping::set(participants, participantAddress, Participant {
            participant_address: participantAddress,
            amount: amount,
        });
    }

    // Function to finish the lottery and determine the winner
    transition finish(old_lottery_state: lottery_state) {
        
        // Only the owner can finish the lottery
        assert_eq(old_lottery_state.owner, self.caller);

        // Calculate the prize for the winner (90% of the total amount)
        let prize: u64 = old_lottery_state.total_amount * 90u64 / 100u64;

        // Calculate the owner's commission (10% of the total amount)
        let ownerCommission: u64 = old_lottery_state.total_amount - prize;

        // Get the winner's address (you can implement a draw_winner function)
        // For simplicity, we'll assume the winner is the owner for now.
        let winner: address = participants[ChaCha::rand_u32()% lottery_state.participants_amount].address;

        // Send the prize to the winner
        Transfer::to_address(winner, prize);

        // Send the owner's commission to the owner (self.caller)
        Transfer::to_address(self.caller, ownerCommission);
        
    }
}
