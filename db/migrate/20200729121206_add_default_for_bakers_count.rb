class AddDefaultForBakersCount < ActiveRecord::Migration[6.0]
  def change
    change_column_default :tezos_chains, :bakers_count, 0
  end
end
