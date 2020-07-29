require "rails_helper"

RSpec.describe Tezos::Chain do
  describe "bakers_count" do
    it "increments when a baker is added" do
      chain = FactoryBot.create(:tezos_chain)
      expect {
        FactoryBot.create(:tezos_baker, chain: chain)
      }.to change(chain, :bakers_count).by(1)
    end
  end
end
