class Tezos::Event < ApplicationRecord
  belongs_to :block
  belongs_to :sender
  belongs_to :receiver
  belongs_to :related_block
end
