class AddGovernance < ActiveRecord::Migration[6.0]
  def change
    create_table "tezos_proposals", id: :string, force: :cascade do |t|
      t.bigint "chain_id", null: false
      t.string "name"
      t.text "description"
      t.string "discussion_url"
      t.datetime "submitted_time", precision: 6, null: false
      t.bigint "submitted_block"
      t.integer "start_period"
      t.boolean "passed_prop_period", default: false
      t.boolean "passed_eval_period", default: false
      t.boolean "is_promoted", default: false
      t.index ["chain_id"], name: "index_tezos_proposals_on_chain_id"
    end

    create_table "tezos_voting_periods", force: :cascade do |t|
      t.bigint "chain_id", null: false
      t.string "period_type"
      t.datetime "period_start_time", precision: 6
      t.datetime "period_end_time", precision: 6
      t.string "period_start_block"
      t.string "period_end_block"
      t.boolean "all_blocks_synced", default: false
      t.integer "quorum"
      t.jsonb "voting_power"
      t.index ["chain_id"], name: "index_tezos_voting_proposals_on_chain_id"
    end

    create_table "tezos_ballots", id: :string, force: :cascade do |t|
      t.bigint "chain_id"
      t.integer "voting_period"
      t.string "proposal_id"
      t.string "baker_id"
      t.string "vote"
      t.integer "rolls"
      t.datetime "created_at", precision: 6
      t.string "block_id"
      t.index ["chain_id"], name: "index_tezos_ballots_on_chain_id"
      t.index ["proposal_id"], name: "index_tezos_ballots_on_proposal_id"
      t.index ["baker_id"], name: "index_tezos_ballots_on_baker_id"
      t.index ["voting_period"], name: "index_tezos_ballots_on_voting_period"
    end

    add_foreign_key "tezos_proposals", "tezos_chains", column: "chain_id", on_delete: :cascade
    add_foreign_key "tezos_voting_periods", "tezos_chains", column: "chain_id", on_delete: :cascade
    add_foreign_key "tezos_ballots", "tezos_chains", column: "chain_id", on_delete: :cascade
    add_foreign_key "tezos_ballots", "tezos_proposals", column: "proposal_id", on_delete: :cascade
    add_foreign_key "tezos_ballots", "tezos_voting_periods", column: "voting_period", on_delete: :cascade
    add_foreign_key "tezos_ballots", "tezos_bakers", column: "baker_id", on_delete: :cascade
  end
end
