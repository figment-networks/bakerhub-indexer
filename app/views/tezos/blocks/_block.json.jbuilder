json.extract! block, :id, :missed?, :baker_id, :intended_baker_id, :baker_priority, :missed_slot_details
json.missed_bakes block.missed_bakes, :baker_id, :priority
