class Tezos::BlocksController < ApplicationController
  before_action :set_tezos_block, only: [:show]

  # GET /tezos/blocks
  # GET /tezos/blocks.json
  def index
    limit = params[:limit] || 10
    @tezos_blocks = Tezos::EndorsedBlock.includes(:missed_bakes).order(id: :desc).limit(limit)
  end

  # GET /tezos/blocks/1
  # GET /tezos/blocks/1.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tezos_block
      @tezos_block = if params[:id] == "latest"
        Tezos::EndorsedBlock.order(id: :desc).first
      else
        Tezos::EndorsedBlock.find(params[:id])
      end
    end
end
