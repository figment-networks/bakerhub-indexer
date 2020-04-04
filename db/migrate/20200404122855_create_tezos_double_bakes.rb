class CreateTezosDoubleBakes < ActiveRecord::Migration[6.0]
  def change
    create_table :tezos_double_bakes do |t|
      t.belongs_to :block, null: false, foreign_key: { to_table: :tezos_blocks }
      t.string :height
      t.string :accuser
      t.string :offender
      t.bigint :reward
    end
  end
end
