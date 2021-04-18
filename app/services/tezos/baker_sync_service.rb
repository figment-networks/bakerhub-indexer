module Tezos
  class BakerSyncService
    include Tezos::Timer

    attr_reader :chain, :latest_block

    def initialize(chain, latest_block)
      @chain = chain
      @latest_block = latest_block
    end

    def run
      time "Syncing bakers" do
        url = Tezos::Rpc.new(chain).url("blocks/#{latest_block}/context/raw/json/delegates")
        res = Typhoeus.get(url)
        all_bakers = JSON.parse(res.body)

        url = Tezos::Rpc.new(chain).url("blocks/#{latest_block}/context/delegates", "active=true")
        res = Typhoeus.get(url)
        active_bakers = JSON.parse(res.body)

        found_bakers = Tezos::Baker.pluck(:id)
        missing_bakers = all_bakers - found_bakers

        missing_bakers.each do |id|
          Tezos::Baker.create(id: id, chain: chain, active: active_bakers.include?(id))
        end
      end

      time "Update baker names from BakingBad" do
        baking_bad_bakers = BakingBad::Baker.list
        if baking_bad_bakers
          local_bakers = chain.bakers.where(name: nil, url: nil).index_by(&:address)
          baking_bad_bakers.each do |baker|
            local_baker = local_bakers[baker.address]
            next unless local_baker
            local_baker.update_columns(name: baker.name, url: baker.site)
          end
        end
      end
    end
  end
end
