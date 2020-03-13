class Tezos::EndorsedBlock < ActiveRecord::Base
  self.primary_key = :id

  belongs_to :cycle

  def readonly?
    true
  end

  def endorsement_results
    @endorsement_results ||= Tezos::EndorsementResults.new(height: id, bitmask: self[:endorsed_slots], endorsers: endorsers) if self[:endorsed_slots].present?
  end

  delegate :missed?, :endorsed?, :by_slot,
           :total_slots, :total_slots_count,
           :endorsed_slots, :endorsed_slots_count,
           :missed_slots, :missed_slots_count, :missed_slot_details,
           to: :endorsement_results, allow_nil: true
end
