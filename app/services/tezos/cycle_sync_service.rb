module Tezos
  class CycleSyncService
    include Tezos::Timer

    attr_reader :chain, :cycle_number, :latest_block

    def initialize(chain, cycle_number, latest_block)
      @chain = chain
      @cycle_number = cycle_number
      @latest_block = latest_block
    end

    def run
      create_cycle
      get_block_info
      get_endorsing_rights
      import_blocks
      get_missed_bakes
      cache_stats
    end

    def create_cycle
      time "Creating cycle #{cycle_number}" do
        @cycle = Tezos::Cycle.find_or_create_by(id: cycle_number, chain: chain)
        @cycle.get_constants_from_rpc
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

    def cache_stats
      # CACHE ENDORSING STATS
      time "Caching endoring stats, baking stats, blocks count" do
        @cycle.update_columns(
          cached_endorsing_stats: @cycle.endorsing_stats,
          cached_baking_stats: @cycle.baking_stats,
          blocks_count: @cycle.blocks.count
        )
      end

      # CACHE START / END TIMES
      time "Caching cycle start & end times" do
        @cycle.update_columns(cached_start_time: @cycle.start_time, cached_end_time: @cycle.end_time) if @cycle.blocks_count > 0
      end

      # CACHE ALL_BLOCKS_SYNCED
      time "Caching all_blocks_synced" do
        if @cycle.blocks_count == @cycle.blocks_per_cycle ||
            @cycle.number == 0 && @cycle.blocks_count == @cycle.blocks_per_cycle - 1
          @cycle.update_columns(all_blocks_synced: true)
        end
      end
    end
  end
end
