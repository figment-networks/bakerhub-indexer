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

      sync = Tezos::EndorsersSyncService.new(block.chain, block.height)
      url = sync.send(:url)

      json = [
        {
          slots: [ 0, 1, 2, 3 ],
          delegate: "test123"
        }
      ].to_json
      endorsers_array = ["test123", "test123", "test123", "test123"]

      response = Typhoeus::Response.new(code: 200, body: json)
      Typhoeus.stub(url).and_return(response)
      
      expect(block.endorsers).to eq endorsers_array
    end
  end
end
