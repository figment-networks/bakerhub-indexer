class Tezos::EventsController < ApplicationController
  include Pagy::Backend

  before_action :set_tezos_cycle, only: [:index]

  # GET /tezos/cycles/:id/events
  # GET /tezos/cycles/:id/events.json
  def index
    events = @tezos_cycle.events.order(block_id: :desc)
    # TODO: Filter according to params[:types]
    @pagy, @events = pagy(events)
    events_json = @events.as_json(methods: :type)
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
