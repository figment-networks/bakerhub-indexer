class Tezos::Ballot < ApplicationRecord
  belongs_to :chain
  belongs_to :voting_period
  belongs_to :proposal
  belongs_to :baker

  def prop_name
    self.proposal.name
  end
end
