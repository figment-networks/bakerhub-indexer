class Tezos::DoubleBake < ApplicationRecord
  belongs_to :block
  belongs_to :accuser, class_name: "Tezos::Baker", foreign_key: :accuser
  belongs_to :offender, class_name: "Tezos::Baker", foreign_key: :offender
end
