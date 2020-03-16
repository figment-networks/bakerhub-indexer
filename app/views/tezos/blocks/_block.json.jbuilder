json.extract! block, :id, :baker_id, :intended_baker_id, :baker_priority, :missed_slot_details
json.missed block.missed?
json.missed_bakes block.missed_bakes, :baker_id, :priority
