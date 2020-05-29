class Tezos::Chain < ApplicationRecord
  SNAPSHOT_DELAY_CYCLES = 2

  has_many :bakers
  has_many :cycles
  has_many :voting_periods
  has_many :ballots

  alias_attribute :ext_id, :slug

  scope :primary, -> { find_by(primary: true) || order(created_at: :desc).first }
end
