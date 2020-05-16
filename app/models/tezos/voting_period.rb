class Tezos::VotingPeriod < ApplicationRecord
  belongs_to :chain
  has_many :ballots

end
