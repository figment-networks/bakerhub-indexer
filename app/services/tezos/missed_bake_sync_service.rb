module Tezos
  class MissedBakeSyncService
    include Tezos::Timer

    attr_reader :cycle

    def initialize(cycle)
      @cycle = cycle
    end

    def run
      time "Detecting missed bakes" do
        # TODO: Save this and current max baker priority; only re-run if needed
        rights = Tezos::Rpc.get(
          "/blocks/#{cycle.start_height}/helpers/baking_rights",
          "cycle=#{cycle.number}&max_priority=#{cycle.blocks.maximum(:baker_priority) + 1}&all"
        )

        missed_bakes = []
        intended_bakers = {}

        cycle.blocks.missed.where(intended_baker_id: nil).find_each do |block|
          block_rights = rights.select { |r| r["level"] == block.height }
          block_rights.each do |r|
            if r["priority"] < block.baker_priority
              missed_bakes << { block_id: block.id, baker_id: r["delegate"], priority: r["priority"] }
            end
          end
          intended_bakers[block.id.to_s] = block_rights.find { |r| r["priority"] == 0 }["delegate"]
        end

        intended_bakers.each do |height, baker_id|
          Tezos::Baker.find_or_create_by(id: baker_id, chain: cycle.chain)
          Tezos::Block.find(height.to_i).update_columns(intended_baker_id: baker_id)
        end
        Tezos::MissedBake.import missed_bakes, validate: false
      end
    end
  end
end
