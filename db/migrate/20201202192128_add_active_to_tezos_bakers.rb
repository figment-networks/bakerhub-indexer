class AddActiveToTezosBakers < ActiveRecord::Migration[6.0]
  def change
    add_column :tezos_bakers, :active, :boolean
  end
end
