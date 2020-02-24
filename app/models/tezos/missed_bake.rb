class Tezos::MissedBake < ApplicationRecord
  belongs_to :baker
  belongs_to :block
end
