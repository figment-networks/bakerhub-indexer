class Tezos::EventsController < ApplicationController
  include Pagy::Backend

  before_action :set_tezos_cycle, only: [:index]

  # GET /tezos/cycles/:id/events
  # GET /tezos/cycles/:id/events.json
  def index
    @blocks = @tezos_cycle.endorsed_blocks.includes(:baker, missed_bakes: :baker, double_bakes: [:accuser, :offender], double_endorsements: [:accuser, :offender]).order(id: :desc)

    # @blocks = if params[:types].nil? || ((params[:types].include?("missed_bakes") || params[:types].include?("steals")) && params[:types].include?("missed_endorsements"))
    #   @blocks.with_events
    # elsif (params[:types].include?("missed_bakes") || params[:types].include?("steals")) && params[:types].exclude?("missed_endorsements")
    #   @blocks.missed
    # elsif params[:types].exclude?("missed_bakes") && params[:types].exclude?("steals") && params[:types].include?("missed_endorsements")
    #   @blocks.with_missed_slots
    # end

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

      if params[:types].nil? || params[:types].include?("double_bakes")
        block.double_bakes.each do |double_bake|
          events << {
            type: "double_bake",
            height: double_bake.block_id,
            related_height: double_bake.height,
            baker_address: double_bake[:accuser],
            baker_name: double_bake.accuser.name,
            offender_address: double_bake[:offender],
            offender_name: double_bake.offender.name,
            reward: double_bake.reward
          }
        end
      end

      if params[:types].nil? || params[:types].include?("double_endorsements")
        block.double_endorsements.each do |double_endorsement|
          events << {
            type: "double_endorsement",
            height: double_endorsement.block_id,
            related_height: double_endorsement.height,
            baker_address: double_endorsement[:accuser],
            baker_name: double_endorsement.accuser.name,
            offender_address: double_endorsement[:offender],
            offender_name: double_endorsement.offender.name,
            reward: double_endorsement.reward
          }
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
