class Tezos::EventsController < ApplicationController
  include Pagy::Backend

  before_action :set_tezos_cycle, only: [:index]

  # GET /tezos/cycles/:id/events
  # GET /tezos/cycles/:id/events.json
  def index
    events = if @tezos_cycle
      @tezos_cycle.events.includes(:block, :sender, :receiver).order(block_id: :desc)
    else
      Tezos::Event.includes(:block, :sender, :receiver).order(block_id: :desc).references(:block)
    end

    if params[:types]
      types = params[:types].map { |t| "Tezos::Event::#{t.classify}" }
      events = events.where(type: types)
    end

    if params[:after_timestamp].present?
      events = events.where("tezos_blocks.timestamp > ?", Time.at(params[:after_timestamp].to_i))
    end

    if params[:before_timestamp].present?
      events = events.where("tezos_blocks.timestamp < ?", Time.at(params[:before_timestamp].to_i))
    end

    if params[:after_height].present?
      events = events.where("block_id > ?", params[:after_height].to_i)
    end

    events = events.where.not("data @> ?", { initial: true }.to_json)

    if params[:paginate] == 'false'
      @pagy = {}
      @events = events
    else
      @pagy, @events = pagy(events)
    end
  end

  private

    def set_tezos_cycle
      return if params[:cycle_id].nil?
      @tezos_cycle = if params[:cycle_id] == "current"
        Tezos::Cycle.order(id: :desc).first
      elsif params[:cycle_id] == "latest_completed"
        Tezos::Cycle.where(all_blocks_synced: true).order(id: :desc).first
      else
        Tezos::Cycle.find(params[:cycle_id])
      end
    end
end
