class AddLatestMissedEndorsementSyncedToTezosCycles < ActiveRecord::Migration[6.0]
  def change
    add_column :tezos_cycles, :latest_missed_endorsement_synced, :bigint, default: 0
  end
end
