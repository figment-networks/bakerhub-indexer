module Tezos
  class MissedEndorsementSyncService
    include Tezos::Timer

    attr_reader :cycle

    def initialize(cycle)
      @cycle = cycle
    end

    def run
      time "Detecting missed endorsements" do
        events = []
        blocks = cycle.endorsed_blocks.where("id > ?", cycle.latest_missed_endorsement_synced).order(id: :asc)

        blocks.find_each do |block|
          block.missed_slots.each do |slot|
            baker = Tezos::Baker.find_or_create_by(
              id: block.endorsers[slot - 1],
              chain: cycle.chain
            )

            events << {
              type: "Tezos::Event::MissedEndorsement",
              block_id: block.id,
              sender_id: baker.id,
              slot: slot
            }
          end
        end

        Tezos::Event.import events, validate: false
        cycle.update(latest_missed_endorsement_synced: blocks.last.id) if blocks.any?
      end
    end
  end
end
