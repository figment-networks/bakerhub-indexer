class Tezos::Event < ApplicationRecord
  belongs_to :block
  belongs_to :sender, class_name: "Tezos::Baker"
  belongs_to :receiver, class_name: "Tezos::Baker"
  belongs_to :related_block, class_name: "Tezos::Block"

  delegate :name, to: :sender, prefix: true
  delegate :name, to: :receiver, prefix: true, allow_nil: true
end
