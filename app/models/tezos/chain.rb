class Tezos::Chain < ApplicationRecord
  SNAPSHOT_DELAY_CYCLES = 2

  has_many :bakers
  has_many :cycles

  alias_attribute :ext_id, :slug
end
