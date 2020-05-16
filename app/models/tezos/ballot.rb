class Tezos::Ballot < ApplicationRecord
  belongs_to :proposal
  belongs_to :voting_period

end
