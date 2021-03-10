class AddBlocksToTezosVotingPeriods < ActiveRecord::Migration[6.0]
  def change
    add_column :tezos_voting_periods, :start_position, :integer
    add_column :tezos_voting_periods, :end_position, :integer
  end
end
