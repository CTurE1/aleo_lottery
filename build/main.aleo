program wright_lottery.aleo;

struct Participant:
    participant_address as address;
    amount as u64;

record lottery_state:
    owner as address.private;
    total_amount as u64.private;
    participants_amount as u32.private;


mapping participants:
	key left as address.public;
	value right as Participant.public;

function initialize_lottery:
    cast self.caller 0u64 0u32 into r0 as lottery_state.record;
    output r0 as lottery_state.record;


function buy_ticket:
    input r0 as address.private;
    input r1 as u64.private;
    input r2 as lottery_state.record;
    gt r1 0u64 into r3;
    assert.eq r3 true;
    add r2.total_amount r1 into r4;
    add r2.participants_amount 1u32 into r5;
    cast r2.owner r4 r5 into r6 as lottery_state.record;
    output r6 as lottery_state.record;

    finalize r0 r1;

finalize buy_ticket:
    input r0 as address.public;
    input r1 as u64.public;
    cast r0 r1 into r2 as Participant;
    set r2 into participants[r0];


function finish:
    input r0 as lottery_state.record;
    assert.eq r0.owner self.caller;
    mul r0.total_amount 90u64 into r1;
    div r1 100u64 into r2;
    sub r0.total_amount r2 into r3;
