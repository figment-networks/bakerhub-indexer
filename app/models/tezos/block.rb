class Tezos::Block < ApplicationRecord
  belongs_to :cycle, counter_cache: true
  has_one :chain, through: :cycle
  belongs_to :baker
  belongs_to :intended_baker, class_name: "Tezos::Baker", inverse_of: :baking_rights, optional: true
  has_many :missed_bakes
  has_many :events
  has_many :missed_bake_events, class_name: "Tezos::Event::MissedBake"
  has_many :missed_endorsement_events, class_name: "Tezos::Event::MissedEndorsement"
  has_many :steal_events, class_name: "Tezos::Event::Steal"
  has_many :double_bake_events, class_name: "Tezos::Event::DoubleBake"
  has_many :double_endorsement_events, class_name: "Tezos::Event::DoubleEndorsement"

  scope :baked_by, -> (baker) { where(baker: baker) }
  scope :baked, -> { where.not(baker_id: nil) }
  scope :missed, -> { baked.where.not(baker_priority: 0) }

  alias_method :height, :id

  def stolen?
    baker_priority > 0
  end

  def missed?
    stolen?
  end

  def timestamp
    return self[:timestamp] if self[:timestamp].present?
    data = Tezos::Rpc.get("blocks/#{id}/header")
    time = Time.parse(data["timestamp"])
    update_columns(timestamp: time)
    return time
  end

  def endorsers
    return self[:endorsers] if self[:endorsers].present?

    a = []
    url = Tezos::Rpc.new(chain).url("blocks/#{height}/helpers/endorsing_rights")
    res = Typhoeus.get(url)
    data = JSON.parse(res.body)
    data.each do |right|
      right["slots"].each do |slot|
        a[slot] = right["delegate"]
      end
    end

    update_columns(endorsers: a)

    return a
  end
end
