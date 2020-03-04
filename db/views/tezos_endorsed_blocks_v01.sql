SELECT tezos_blocks.id,
  tezos_blocks.cycle_id,
  tezos_blocks.baker_id,
  tezos_blocks.baker_priority,
  tezos_blocks.id_hash,
  tezos_blocks.intended_baker_id,
  tezos_blocks.endorsers,
  tezos_blocks.timestamp,
  next_block.endorsed_slots
FROM (tezos_blocks
 JOIN tezos_blocks next_block ON ((next_block.id = (tezos_blocks.id + 1))));
