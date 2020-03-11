class Tezos::MissedBake < ApplicationRecord
  belongs_to :baker
  belongs_to :block
  has_one :cycle, through: :block
end
