module Tezos
  class BakerActivationsSyncService
    include Tezos::Timer

    attr_reader :chain, :latest_block, :current_cycle, :baker

    def initialize(chain, block_data)
      @chain = chain
      @latest_block = block_data.level
      @current_cycle = block_data.cycle
      @baker = block_data.baker
    end

    def run
      time "Syncing baker activations and deactivations" do
        url = Tezos::Rpc.new(chain).url("blocks/#{latest_block}/context/raw/json/delegates")
        res = Typhoeus.get(url)
        all_bakers = JSON.parse(res.body)

        url = Tezos::Rpc.new(chain).url("blocks/#{latest_block}/context/delegates", "active=true")
        res = Typhoeus.get(url)
        active_bakers = JSON.parse(res.body)

        inactive_bakers = all_bakers - active_bakers

        # Backfill actie flag for bakers that were added without it set
        Tezos::Baker.where(active: nil, id: active_bakers).update_all(active: true)
        Tezos::Baker.where(active: nil, id: inactive_bakers).update_all(active: false)

        # Need to do this after blocks have been imported since events belong to blocks...
        Tezos::Baker.where(active: false, id: active_bakers).each do |baker|
          Tezos::Event::BakerActivated.create(
            block_id: latest_block,
            sender_id: baker.id
          )
          baker.update(active: true)
        end

        Tezos::Baker.where(active: true, id: inactive_bakers).each do |baker|
          Tezos::Event::BakerDeactivated.create(
            block_id: latest_block,
            sender_id: baker.id
          )
          baker.update(active: false)
        end

        if Rails.env.development?
          cycle = Tezos::Cycle.find_or_create_by(id: current_cycle, chain: chain)
          block = Tezos::Block.find_or_create_by(id: latest_block, cycle: cycle, baker_id: baker)
        end

        active_bakers[0..1].each do |id|
          baker = Tezos::Baker.find(id)
          last_balance_change_event = baker.balance_change_events.order(block_id: :asc).last

          if last_balance_change_event.nil?
            event = Tezos::Event::BalanceChange.create(
              sender_id: id,
              from: nil,
              to: baker.balance(block: latest_block),
              initial: true,
              block_id: latest_block
            )
          else
            event = Tezos::Event::BalanceChange.new(
              sender_id: id,
              from: last_balance_change_event.to,
              to: baker.balance(block: latest_block),
              block_id: latest_block
            )
            event.save if event.significant?
          end
        end
      end
    end
  end
end
