module Tezos
  class CycleSyncService
    include Tezos::Timer

    attr_reader :chain, :cycle_number, :cycle, :latest_block

    def initialize(chain, cycle_number, latest_block)
      @chain = chain
      @cycle_number = cycle_number
      @latest_block = latest_block
      @cycle = Tezos::Cycle.find_or_create_by(id: cycle_number, chain: chain)
    end

    def run
      get_cycle_constants
      get_block_info
      get_endorsing_rights
      import_blocks
      get_missed_bakes
      get_snapshot_height
      get_total_rolls
      cache_stats
    end

    def get_cycle_constants
      time "Getting constants for cycle #{cycle_number}" do
        cycle.get_constants_from_rpc
      end
    end

    def get_block_info
    end

    def get_endorsing_rights
    end

    def import_blocks
    end

    def get_missed_bakes
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
  end
end
