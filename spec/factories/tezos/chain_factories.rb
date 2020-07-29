FactoryBot.define do
  factory :tezos_chain, class: "Tezos::Chain" do
    name { "Mainnet" }
    slug { "mainnet" }
    internal_name { "NetXdQprcVkpaWU" }
    rpc_host { "123.123.123.123" }
    rpc_port { "443" }
    rpc_path { "/apikey/asdf123" }
    use_ssl_for_rpc { true }
  end
end
