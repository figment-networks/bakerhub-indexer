class Tezos::ProposalsController < ApplicationController
  before_action :set_tezos_proposal, only: [:show]

  # GET /tezos/proposals
  # GET /tezos/proposals.json
  def index
    @tezos_proposals = Tezos::Proposal.all
  end

  # GET /tezos/proposals/1
  # GET /tezos/proposals/1.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tezos_proposal
      @tezos_proposal = Tezos::Proposal.find(params[:id])
    end
end
