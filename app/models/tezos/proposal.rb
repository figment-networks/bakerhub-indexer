class Tezos::Proposal < ApplicationRecord
  belongs_to :chain
  has_many :ballots

end
