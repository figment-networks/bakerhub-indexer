module Tezos
  class CycleSyncService
    include Tezos::Timer

    attr_reader :chain, :cycle_number, :cycle, :latest_block, :blocks, :events

    def initialize(chain, cycle_number, latest_block)
      @chain = chain
      @cycle_number = cycle_number
      @latest_block = latest_block
      @cycle = Tezos::Cycle.find_or_create_by(id: cycle_number, chain: chain)
      @blocks = {}
      @events = []
    end

    def run
      get_cycle_constants
      get_block_info
      import_blocks
      get_missed_bakes
      get_missed_endorsements
      get_snapshot_height
      get_total_rolls
      cache_stats

      # If this cycle is over but we haven't gotten all blocks, run again
      if !cycle.all_blocks_synced? && cycle.end_height < latest_block
        run
      end
    end

    def get_cycle_constants
      time "Getting constants for cycle #{cycle_number}" do
        cycle.get_constants_from_rpc
      end
    end

    def get_block_info
      start_height = cycle.start_height
      end_height = [cycle.end_height, latest_block].min
      all_heights = (start_height..end_height).to_a
      found_heights = cycle.blocks.pluck(:id)
      missing_heights = all_heights - found_heights

      if missing_heights.any?
        time "Get info for #{missing_heights.length} blocks #{missing_heights.first}..#{missing_heights.last}" do
          missing_heights.each do |height|
            next if height == 1

            url = Tezos::Rpc.new(chain).url("blocks/#{height}")
            request = Typhoeus::Request.new(url, method: :get)

            request.on_complete do |response|
              if response.success?
                begin
                  block_info = JSON.parse(response.body)

                  ## Calculate bitmask of endorsed slots for previous block ##################
                  if height > 2
                    res = Tezos::EndorsementResults.new(height: height, bitmask: 0, endorsers: [])

                    block_info["operations"].flatten.each do |op|
                      endorsements = op["contents"].select { |subop| subop["kind"] == "endorsement" }
                      endorsements.each do |endorsement|
                        endorsement["metadata"]["slots"].each do |slot|
                          res.set_true(slot + 1) # slots are 1-indexed in EndorsementResults and 0-indexed in RPC result
                        end
                      end

                      double_baking_ops = op["contents"].select { |subop| subop["kind"] == "double_baking_evidence" }
                      double_baking_ops.each do |o|
                        data = {
                          type: "Tezos::Event::DoubleBake",
                          block_id: height,
                          related_block_id: o["bh1"]["level"],
                          sender_id: nil,
                          receiver_id: nil,
                          reward: nil
                        }

                        o["metadata"]["balance_updates"].each do |update|
                          if update["category"] == "rewards" && update["change"].to_i < 0
                            data[:receiver_id] = update["delegate"]
                          elsif update["category"] == "rewards" && update["change"].to_i > 0
                            data[:sender_id] = update["delegate"]
                            data[:reward]  = update["change"].to_i
                          end
                        end

                        events << data
                      end

                      double_endorsement_ops = op["contents"].select { |subop| subop["kind"] == "double_endorsement_evidence" }
                      double_endorsement_ops.each do |o|
                        data = {
                          type: "Tezos::Event::DoubleEndorsement",
                          block_id: height,
                          related_block_id: o["op1"]["operations"]["level"],
                          sender_id: nil,
                          receiver_id: nil,
                          reward: nil
                        }

                        o["metadata"]["balance_updates"].each do |update|
                          if update["category"] == "rewards" && update["change"].to_i < 0
                            data[:receiver_id] = update["delegate"]
                          elsif update["category"] == "rewards" && update["change"].to_i > 0
                            data[:sender_id] = update["delegate"]
                            data[:reward]  = update["change"].to_i
                          end
                        end

                        events << data
                      end
                    end
                  end
                  ############################################################################

                  blocks[height.to_s] = {
                    id: height,
                    id_hash: block_info["hash"],
                    cycle_id: cycle.number,
                    timestamp: Time.parse(block_info["header"]["timestamp"]),
                    baker_id: block_info["metadata"]["baker"],
                    baker_priority: block_info["header"]["priority"],
                    endorsed_slots: res&.bitmask,
                  }

                  url = Tezos::Rpc.new(chain).url("blocks/#{height}/helpers/endorsing_rights")
                  request2 = Typhoeus::Request.new(url, method: :get)

                  request2.on_complete do |response|
                    if response.success?
                      endorsers = []
                      data = JSON.parse(response.body)

                      data.each do |right|
                        right["slots"].each do |slot|
                          endorsers[slot] = right["delegate"]
                        end
                      end

                      blocks[height.to_s][:endorsers] = endorsers
                    end
                  end

                  hydra.queue(request2)
                rescue Exception => e
                  puts "ERROR PARSING BLOCK #{height}"
                  puts response.body
                end
              end
            end

            hydra.queue(request)
          end

          hydra.run
        end
      end
    end

    def import_blocks
      Tezos::Block.import blocks.values, validate: false
      Tezos::Event.import events, validate: false
    end

    def get_missed_bakes
      Tezos::MissedBakeSyncService.new(cycle).run
    end

    def get_missed_endorsements
      Tezos::MissedEndorsementSyncService.new(cycle).run
    end

    def get_snapshot_height
      time "Getting snapshot height for cycle #{cycle_number}" do
        if cycle.needs_snapshot?
          snapshot_cycle = Tezos::Cycle.find(cycle.snapshot_cycle_number)
          url = Tezos::Rpc.new(chain).url("blocks/#{cycle.start_height}/context/raw/json/cycle/#{cycle.number}/roll_snapshot")
          res = Typhoeus.get(url)
          snapshot_index = JSON.parse(res.body)
          snapshot_height = ((cycle.snapshot_cycle_number) * snapshot_cycle.blocks_per_cycle + 1) + (snapshot_index + 1) * snapshot_cycle.blocks_per_roll_snapshot - 1
          if snapshot_height > 1 && Tezos::Block.find_by(id: snapshot_height).present?
            cycle.update_columns(snapshot_id: snapshot_height)
          end
        end
      end
    end

    def get_total_rolls
      time "Getting total rolls for cycle #{cycle_number}" do
        return if cycle.snapshot.nil? || cycle.total_rolls.present?
        url = Tezos::Rpc.new(chain).url("blocks/#{cycle.snapshot.id_hash}/context/raw/json/rolls/owner/current")
        res = Typhoeus.get(url)
        data = JSON.parse(res.body)
        total_rolls = data.is_a?(Array) ? data.length : nil
        cycle.update_columns(total_rolls: total_rolls)
      end
    end

    def cache_stats
      cycle.reload

      time "Caching endoring stats, baking stats, blocks count" do
        cycle.update_columns(
          cached_endorsing_stats: cycle.endorsing_stats,
          cached_baking_stats: cycle.baking_stats,
          blocks_count: cycle.blocks.count
        )
      end

      time "Caching cycle start & end times" do
        cycle.update_columns(cached_start_time: cycle.start_time, cached_end_time: cycle.end_time) if cycle.blocks_count > 0
      end

      time "Caching all_blocks_synced" do
        if cycle.blocks_count == cycle.blocks_per_cycle ||
            cycle.number == 0 && cycle.blocks_count == cycle.blocks_per_cycle - 1
          cycle.update_columns(all_blocks_synced: true)
        end
      end
    end

    private

    def hydra
      @hydra ||= Typhoeus::Hydra.new(max_concurrency: 100)
    end
  end
end
