class Tezos::EndorsedBlock < ActiveRecord::Base
  self.primary_key = :id

  belongs_to :cycle
  belongs_to :baker
  has_many :missed_bakes, foreign_key: :block_id

  alias_method :height, :id

  delegate :missed?, :endorsed?, :by_slot,
           :total_slots, :total_slots_count,
           :endorsed_slots, :endorsed_slots_count,
           :missed_slots, :missed_slots_count, :missed_slot_details,
           to: :endorsement_results, allow_nil: true

  def readonly?
    true
  end

  def self.missed
    where("baker_priority > 0")
  end

  def self.with_missed_slots
    where.not(endorsed_slots: 4294967295)
  end

  def endorsement_results
    @endorsement_results ||= Tezos::EndorsementResults.new(height: id, bitmask: self[:endorsed_slots], endorsers: endorsers) if self[:endorsed_slots].present?
  end

  def stolen?
    baker_priority > 0
  end

  def missed?
    stolen?
  end
end
