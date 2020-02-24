json.extract! tezos_cycle, :number,
                           :snapshot_cycle_number,
                           :snapshot_height,
                           :total_rolls,
                           :start_height,
                           :end_height
json.start_time tezos_cycle.cached_start_time.to_i
json.end_time tezos_cycle.cached_end_time.to_i
json.seconds_remaining tezos_cycle.seconds_remaining
json.blocks_left tezos_cycle.blocks_left
json.missed_priorities tezos_cycle.cached_baking_stats[:missed_priorities]
json.missed_slots tezos_cycle.cached_endorsing_stats[:total].missed_slots
json.url tezos_cycle_url(tezos_cycle, format: :json)
