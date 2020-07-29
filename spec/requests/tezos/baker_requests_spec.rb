require "rails_helper"

RSpec.describe "Tezos Baker requests", type: :request do
  it "returns the correct bakers count" do
    baker = create(:tezos_baker)
    get "/tezos/bakers/count"
    
    expected_response = { bakers_count: baker.chain.bakers_count }.to_json
    
    expect(response.content_type).to eq("application/json; charset=utf-8")
    expect(response.body).to eq(expected_response)
  end
end
