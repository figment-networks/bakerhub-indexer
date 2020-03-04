class AddRpcFieldsToTezosChains < ActiveRecord::Migration[6.0]
  def change
    add_column :tezos_chains, :rpc_port, :string, default: 8732
    add_column :tezos_chains, :rpc_path, :string
    add_column :tezos_chains, :use_ssl_for_rpc, :boolean, default: true
  end
end
