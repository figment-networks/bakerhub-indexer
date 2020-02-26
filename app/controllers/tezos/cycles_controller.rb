class Tezos::CyclesController < ApplicationController
  before_action :set_tezos_cycle, only: [:show]

  # GET /tezos/cycles
  # GET /tezos/cycles.json
  def index
    @tezos_cycles = Tezos::Cycle.order(id: :asc)
  end

  # GET /tezos/cycles/1
  # GET /tezos/cycles/1.json
  def show
  end

  private

    def set_tezos_cycle
      @tezos_cycle = if params[:id] == "current"
        Tezos::Cycle.order(id: :desc).first
      else
        Tezos::Cycle.find(params[:id])
      end
    end
end
