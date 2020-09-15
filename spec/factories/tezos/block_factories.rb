FactoryBot.define do
  factory :tezos_block, class: "Tezos::Block" do
    chain factory: :tezos_chain
    baker factory: :tezos_baker
    baker_priority { 1 }
    endorsed_slots { 4294967295 }
    timestamp { 2.minutes.ago }
  end
end
