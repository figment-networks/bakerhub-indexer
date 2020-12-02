module Tezos
  class BakerSyncService
    include Tezos::Timer

    attr_reader :chain

    def initialize(chain)
      @chain = chain
    end

    def run
      time "Syncing bakers" do
        url = Tezos::Rpc.new(chain).url("blocks/head/context/raw/json/delegates")
        res = Typhoeus.get(url)
        all_bakers = JSON.parse(res.body)

        url = Tezos::Rpc.new(chain).url("blocks/head/context/delegates", "active=true")
        res = Typhoeus.get(url)
        active_bakers = JSON.parse(res.body)

        inactive_bakers = all_bakers - active_bakers

        found_bakers = Tezos::Baker.pluck(:id)
        missing_bakers = all_bakers - found_bakers

        # Need to backfill active flag, and set for missing bakers when added
        missing_bakers.each do |id|
          Tezos::Baker.create(id: id, chain: chain)
        end

        # Need to set block for these events
        Tezos::Baker.where(active: false, id: active_bakers).each do |baker|
          puts "baker activated #{baker.id}"
        end

        Tezos::Baker.where(active: true, id: inactive_bakers).each do |baker|
          puts "baker deactivated #{baker.id}"
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
