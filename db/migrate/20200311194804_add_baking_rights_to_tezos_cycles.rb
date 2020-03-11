class AddBakingRightsToTezosCycles < ActiveRecord::Migration[6.0]
  def change
    add_column :tezos_cycles, :baking_rights, :jsonb
    add_column :tezos_cycles, :baking_rights_max_priority, :integer
  end
end
