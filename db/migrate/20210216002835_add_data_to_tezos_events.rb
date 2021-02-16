class AddDataToTezosEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :tezos_events, :data, :jsonb, default: {}
  end
end
