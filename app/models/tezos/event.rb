class Tezos::Event < ApplicationRecord
  belongs_to :block
  belongs_to :sender, class_name: "Tezos::Baker"
  belongs_to :receiver, class_name: "Tezos::Baker", optional: true
  belongs_to :related_block, class_name: "Tezos::Block", optional: true

  delegate :name, to: :sender, prefix: true
  delegate :name, to: :receiver, prefix: true, allow_nil: true

  store_accessor :data, :to, :from

  def delta
    nil
  end

  def percent_change
    nil
  end
end
