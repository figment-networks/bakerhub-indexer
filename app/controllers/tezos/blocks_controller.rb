class Tezos::BlocksController < ApplicationController
  before_action :set_tezos_block, only: [:show]

  # GET /tezos/blocks
  # GET /tezos/blocks.json
  def index
    limit = params[:limit] || 10

    @tezos_blocks = Tezos::EndorsedBlock.includes(:missed_bakes).order(id: :desc)

    @tezos_blocks = @tezos_blocks.where("timestamp > ?", Time.at(params[:after].to_i)) if params[:after].present?

    @tezos_blocks = if params[:from].present?
      @tezos_blocks.where("id >= ?", params[:from])
    else
      @tezos_blocks.limit(limit)
    end
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
