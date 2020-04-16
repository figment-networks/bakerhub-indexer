class AddPriorityToTezosEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :tezos_events, :priority, :integer
  end
end
