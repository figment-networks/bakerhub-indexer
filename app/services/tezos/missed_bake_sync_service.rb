module Tezos
  class MissedBakeSyncService
    include Tezos::Timer

    attr_reader :cycle

    def initialize(cycle)
      @cycle = cycle
    end

    def run
      time "Detecting missed bakes" do
        max_priority = cycle.blocks.maximum(:baker_priority)

        if cycle.baking_rights.nil? || cycle.baking_rights_max_priority < max_priority
          rights = Tezos::Rpc.get(
            "/blocks/#{cycle.start_height}/helpers/baking_rights",
            "cycle=#{cycle.number}&max_priority=#{max_priority}&all"
          )
          cycle.update(baking_rights: rights, baking_rights_max_priority: max_priority)
        else
          rights = cycle.baking_rights
        end

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
