class Tezos::VotingPeriodsController < ApplicationController
  before_action :set_tezos_voting_period, only: [:show]

  # GET /tezos/proposals
  # GET /tezos/proposals.json
  def index
    limit = params[:limit] || 10
    @tezos_voting_periods = Tezos::VotingPeriod.order("id desc").limit(limit)
  end

  # GET /tezos/proposals/1
  # GET /tezos/proposals/1.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tezos_voting_period
      @tezos_voting_period = Tezos::VotingPeriod.find(params[:id])
    end
end
