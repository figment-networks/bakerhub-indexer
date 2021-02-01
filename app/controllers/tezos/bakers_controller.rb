class Tezos::BakersController < ApplicationController
  before_action :set_tezos_baker, only: [:show, :staking_balance]

  # GET /tezos/bakers
  # GET /tezos/bakers.json
  def index
    @tezos_bakers = Tezos::Baker.all
    @tezos_bakers = @tezos_bakers.where("LOWER(id) = ? OR name ILIKE ?", params[:query].downcase, "%#{params[:query]}%") if params[:query]
  end

  # GET /tezos/bakers/count.json
  def count
    @count = Tezos::Chain.primary.bakers_count
  end

  # GET /tezos/bakers/1
  # GET /tezos/bakers/1.json
  def show
  end

  # GET /tezos/bakers/:id/staking_balance.json
  def staking_balance
    @block = params[:block]
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tezos_baker
      @tezos_baker = Tezos::Baker.find(params[:id])
    end
end
