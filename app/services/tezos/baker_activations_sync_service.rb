module Tezos
  class BakerActivationsSyncService
    include Tezos::Timer

    attr_reader :chain, :latest_block

    def initialize(chain, latest_block)
      @chain = chain
      @latest_block = latest_block
    end

    def run
      time "Syncing baker activations and deactivations" do
        url = Tezos::Rpc.new(chain).url("blocks/head/context/raw/json/delegates")
        res = Typhoeus.get(url)
        all_bakers = JSON.parse(res.body)

        url = Tezos::Rpc.new(chain).url("blocks/head/context/delegates", "active=true")
        res = Typhoeus.get(url)
        active_bakers = JSON.parse(res.body)

        inactive_bakers = all_bakers - active_bakers

        # Backfill actie flag for bakers that were added without it set
        Tezos::Baker.where(active: nil, id: active_bakers).update_all(active: true)
        Tezos::Baker.where(active: nil, id: inactive_bakers).update_all(active: false)

        # Need to do this after blocks have been imported since events belong to blocks...
        Tezos::Baker.where(active: false, id: active_bakers).each do |baker|
          puts "baker activated #{baker.id} at block #{latest_block}"
        end

        Tezos::Baker.where(active: true, id: inactive_bakers).each do |baker|
          puts "baker deactivated #{baker.id} at block #{latest_block}"
        end
      end
    end
  end
end
