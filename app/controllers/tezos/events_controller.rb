class Tezos::EventsController < ApplicationController
  include Pagy::Backend

  before_action :set_tezos_cycle, only: [:index]

  # GET /tezos/cycles/:id/events
  # GET /tezos/cycles/:id/events.json
  def index
    @pagy, @blocks = pagy(@tezos_cycle.endorsed_blocks.includes(:baker, missed_bakes: :baker).order(id: :desc))

    events = []
    @blocks.each do |block|
      if block.missed?
        events << { type: "steal", height: block.height, baker_address: block.baker_id, baker_name: block.baker.name, timestamp: block.timestamp }

        block.missed_bakes.each do |missed_bake|
          events << { type: "missed_bake", height: block.height, baker_address: missed_bake.baker_id, baker_name: missed_bake.baker.name, timestamp: block.timestamp }
        end
      end

      block.missed_slot_details.each do |details|
        baker = Tezos::Baker.find(details[:baker])
        events << { type: "missed_endorsement", height: block.height, baker_address: details[:baker], baker_name: baker.name, timestamp: block.timestamp, slot: details[:slot] }
      end
    end

    render json: {
      cycle_number: @tezos_cycle.number,
      blocks_count: @blocks.count,
      events: events,
      pagination: @pagy
    }
  end

  private

    def set_tezos_cycle
      @tezos_cycle = if params[:cycle_id] == "current"
        Tezos::Cycle.order(id: :desc).first
      elsif params[:cycle_id] == "latest_completed"
        Tezos::Cycle.where(all_blocks_synced: true).order(id: :desc).first
      else
        Tezos::Cycle.find(params[:cycle_id])
      end
    end
end
