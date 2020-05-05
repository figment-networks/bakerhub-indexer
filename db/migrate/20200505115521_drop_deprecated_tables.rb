class DropDeprecatedTables < ActiveRecord::Migration[6.0]
  def change
    drop_table :tezos_missed_bakes
    drop_table :tezos_double_bakes
    drop_table :tezos_double_endorsements
  end
end
