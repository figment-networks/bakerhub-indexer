FactoryBot.define do
  factory :tezos_baker, class: "Tezos::Baker" do
    id { "tz1Scdr2HsZiQjc7bHMeBbmDRXYVvdhjJbBh" }
    name { "Figment Networks" }
    url { "https://www.figment.network" }
    chain factory: :tezos_chain
  end
end
