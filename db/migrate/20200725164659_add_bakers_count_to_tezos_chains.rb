class AddBakersCountToTezosChains < ActiveRecord::Migration[6.0]
  def up
    add_column :tezos_chains, :bakers_count, :integer, defualt: 0

    Tezos::Chain.reset_column_information
    Tezos::Chain.find_each do |chain|
      Tezos::Chain.update_counters chain.id, bakers_count: chain.bakers.length
    end
  end

  def down
    remove_column :tezos_chains, :bakers_count
  end
end
