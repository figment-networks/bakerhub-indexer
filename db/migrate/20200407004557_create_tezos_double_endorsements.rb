class CreateTezosDoubleEndorsements < ActiveRecord::Migration[6.0]
  def change
    create_table :tezos_double_endorsements do |t|
      t.belongs_to :block, null: false, foreign_key: { to_table: :tezos_blocks }
      t.bigint :height
      t.string :accuser
      t.string :offender
      t.bigint :reward
    end
  end
end
