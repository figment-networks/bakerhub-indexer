class Tezos::BakersController < ApplicationController
  before_action :set_tezos_baker, only: [:show]

  # GET /tezos/bakers
  # GET /tezos/bakers.json
  def index
    @tezos_bakers = Tezos::Baker.all
    @tezos_bakers = @tezos_bakers.where("LOWER(id) = ? OR name ILIKE ?", params[:query].downcase, "%#{params[:query]}%") if params[:query]
  end

  # GET /tezos/bakers/1
  # GET /tezos/bakers/1.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tezos_baker
      @tezos_baker = Tezos::Baker.find(params[:id])
    end
end
