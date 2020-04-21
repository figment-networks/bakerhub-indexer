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
            events << {
              type: "Tezos::Event::MissedEndorsement",
              block_id: block.id,
              sender_id: block.endorsers[slot - 1],
              slot: slot
            }
          end
        end

        Tezos::Event.import events, validate: false
        cycle.update(latest_missed_endorsement_synced: blocks.last.id)
      end
    end
  end
end
