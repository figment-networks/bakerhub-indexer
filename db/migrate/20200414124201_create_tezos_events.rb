class CreateTezosEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :tezos_events do |t|
      t.string :type
      t.belongs_to :block, null: false, foreign_key: { to_table: :tezos_blocks }
      t.belongs_to :related_block, null: true, foreign_key: { to_table: :tezos_blocks }
      t.belongs_to :sender, null: false, type: :string, foreign_key: { to_table: :tezos_bakers }
      t.belongs_to :receiver, null: true, type: :string, foreign_key: { to_table: :tezos_bakers }
      t.bigint :reward
      t.integer :slot
    end
  end
end
