class Tezos::Proposal < ApplicationRecord
  belongs_to :chain
  has_many :voting_periods
  has_many :ballots



end
