class ChangeDoubleBakeHeightToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :tezos_double_bakes, :height, :bigint, using: "height::bigint"
  end

  def down
    change_column :tezos_double_bakes, :height, :string
  end
end
