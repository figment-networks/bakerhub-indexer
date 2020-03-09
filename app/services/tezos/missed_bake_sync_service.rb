# TODO: A better approach might be to get all baking rights (up to certain priority)
# for each cycle, then we can figure out who missed their priorities locally without all these RPC calls

module Tezos
  class MissedBakeSyncService
    include Tezos::Timer

    attr_reader :cycle

    def initialize(cycle)
      @cycle = cycle
    end

    def run
      time "Detecting missed bakes" do
        missed_bakes = []
        intended_bakers = {}

        cycle.blocks.missed.where(intended_baker_id: nil).find_each do |block|
          height = block.id - 1
          url = Tezos::Rpc.new(cycle.chain).url("blocks/#{height}/helpers/baking_rights")
          request = Typhoeus::Request.new(url, method: :get)

          request.on_complete do |response|
            if response.success?
              rights = JSON.parse(response.body)
              rights.each do |r|
                if r["priority"] < block.baker_priority
                  missed_bakes << { block_id: block.id, baker_id: r["delegate"], priority: r["priority"] }
                end
              end
              intended_bakers[block.id.to_s] = rights.find { |r| r["priority"] == 0 }["delegate"]
            end
          end

          hydra.queue(request)
        end

        hydra.run

        intended_bakers.each do |height, baker_id|
          Tezos::Baker.find_or_create_by(id: baker_id, chain: cycle.chain)
          Tezos::Block.find(height.to_i).update_columns(intended_baker_id: baker_id)
        end
        Tezos::MissedBake.import missed_bakes, validate: false
      end
    end

    private

    def hydra
      @hydra ||= Typhoeus::Hydra.new(max_concurrency: 100)
    end
  end
end
