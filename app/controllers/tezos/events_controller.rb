class Tezos::EventsController < ApplicationController
  include Pagy::Backend

  before_action :set_tezos_cycle, only: [:index]

  # GET /tezos/cycles/:id/events
  # GET /tezos/cycles/:id/events.json
  def index
    @blocks = @tezos_cycle.endorsed_blocks.includes(:baker, missed_bakes: :baker, double_bakes: [:accuser, :offender], double_endorsements: [:accuser, :offender]).order(id: :desc)

    @blocks = if params[:types].nil? || ((params[:types].include?("missed_bakes") || params[:types].include?("steals")) && params[:types].include?("missed_endorsements"))
      @blocks.with_events
    elsif (params[:types].include?("missed_bakes") || params[:types].include?("steals")) && params[:types].exclude?("missed_endorsements")
      @blocks.missed
    elsif params[:types].exclude?("missed_bakes") && params[:types].exclude?("steals") && params[:types].include?("missed_endorsements")
      @blocks.with_missed_slots
    end

    @pagy, @blocks = pagy(@blocks)

    events = []
    @blocks.each do |block|
      if block.missed?
        if params[:types].nil? || params[:types].include?("steals")
          events << { type: "steal", height: block.height, baker_address: block.baker_id, baker_name: block.baker.name, timestamp: block.timestamp }
        end

        if params[:types].nil? || params[:types].include?("missed_bakes")
          block.missed_bakes.each do |missed_bake|
            events << { type: "missed_bake", height: block.height, baker_address: missed_bake.baker_id, baker_name: missed_bake.baker.name, timestamp: block.timestamp }
          end
        end
      end

      if params[:types].nil? || params[:types].include?("missed_endorsements")
        block.missed_slot_details.each do |details|
          baker = Tezos::Baker.find(details[:baker])
          events << { type: "missed_endorsement", height: block.height, baker_address: details[:baker], baker_name: baker.name, timestamp: block.timestamp, slot: details[:slot] }
        end
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
