require "rails_helper"

RSpec.describe Tezos::Block do 
  describe "#endorsers" do
    it "returns the value from the databse if present" do
      endorsers_array = ["asdf123"]
      block = create(:tezos_block, endorsers: endorsers_array )
      
      expect(block.endorsers).to eq endorsers_array
    end

    it "falls back to calling endorsers sync service" do
      block = create(:tezos_block, endorsers: nil )

      endorsers_array = ["asdf123", "testing123"]
      callback = -> { block.update(endorsers: endorsers_array) }
      allow_any_instance_of(Tezos::EndorsersSyncService).to receive(:run).and_return(endorsers_array)
      allow_any_instance_of(Tezos::EndorsersSyncService).to receive(:on_success).and_return(callback)
      
      expect(block.endorsers).to eq endorsers_array
    end
  end
end
