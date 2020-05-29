class Tezos::BallotsController < ApplicationController
  before_action :set_tezos_ballot, only: [:show]

  # GET /tezos/ballots
  # GET /tezos/ballots.json
  def index

    limit = params[:limit] || 20

    @tezos_ballots = if params[:proposal_id].present? && params[:voting_period_id].present?
      Tezos::Ballot.where(proposal_id: params[:proposal_id], voting_period_id: params[:voting_period_id])
    elsif params[:proposal_id].present?
      Tezos::Ballot.where(proposal_id: params[:proposal_id])
    elsif params[:voting_period_id].present?
      Tezos::Ballot.where(voting_period_id: params[:voting_period_id])
    else
      Tezos::Ballot.limit(limit)
    end
  end

  # GET /tezos/ballots/1
  # GET /tezos/ballots/1.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tezos_ballot
      @tezos_ballot = Tezos::Ballot.find(params[:id])
    end
end
