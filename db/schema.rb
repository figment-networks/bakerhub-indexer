# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_03_06_000930) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "tezos_bakers", id: :string, force: :cascade do |t|
    t.bigint "chain_id", null: false
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "url"
    t.boolean "active"
    t.index ["chain_id"], name: "index_tezos_bakers_on_chain_id"
  end

  create_table "tezos_ballots", id: :string, force: :cascade do |t|
    t.bigint "chain_id"
    t.integer "voting_period_id"
    t.string "proposal_id"
    t.string "baker_id"
    t.string "vote"
    t.integer "rolls"
    t.datetime "created_at", precision: 6
    t.bigint "submitted_block"
    t.index ["baker_id"], name: "index_tezos_ballots_on_baker_id"
    t.index ["chain_id"], name: "index_tezos_ballots_on_chain_id"
    t.index ["proposal_id"], name: "index_tezos_ballots_on_proposal_id"
    t.index ["voting_period_id"], name: "index_tezos_ballots_on_voting_period"
  end

  create_table "tezos_blocks", force: :cascade do |t|
    t.bigint "cycle_id", null: false
    t.string "baker_id"
    t.integer "baker_priority"
    t.string "id_hash"
    t.string "intended_baker_id"
    t.bigint "endorsed_slots"
    t.jsonb "endorsers"
    t.datetime "timestamp"
    t.index ["baker_id"], name: "index_tezos_blocks_on_baker_id"
    t.index ["cycle_id"], name: "index_tezos_blocks_on_cycle_id"
    t.index ["intended_baker_id"], name: "index_tezos_blocks_on_intended_baker_id"
  end

  create_table "tezos_chains", force: :cascade do |t|
    t.string "name"
    t.string "rpc_host"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "slug"
    t.string "internal_name"
    t.boolean "primary", default: false
    t.string "rpc_port", default: "8732"
    t.string "rpc_path"
    t.boolean "use_ssl_for_rpc", default: true
    t.integer "bakers_count", default: 0
  end

  create_table "tezos_cycles", force: :cascade do |t|
    t.bigint "chain_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "missed_bakes_count"
    t.integer "missed_endorsement_slots_count"
    t.jsonb "constants"
    t.boolean "all_blocks_synced", default: false
    t.jsonb "cached_endorsing_stats"
    t.bigint "snapshot_id"
    t.integer "total_rolls"
    t.jsonb "cached_baking_stats"
    t.datetime "cached_start_time"
    t.datetime "cached_end_time"
    t.integer "blocks_count"
    t.jsonb "baking_rights"
    t.integer "baking_rights_max_priority"
    t.bigint "latest_missed_endorsement_synced", default: 0
    t.index ["chain_id"], name: "index_tezos_cycles_on_chain_id"
    t.index ["snapshot_id"], name: "index_tezos_cycles_on_snapshot_id"
  end

  create_table "tezos_events", force: :cascade do |t|
    t.string "type"
    t.bigint "block_id", null: false
    t.bigint "related_block_id"
    t.string "sender_id", null: false
    t.string "receiver_id"
    t.bigint "reward"
    t.integer "slot"
    t.integer "priority"
    t.jsonb "data", default: {}
    t.index ["block_id"], name: "index_tezos_events_on_block_id"
    t.index ["receiver_id"], name: "index_tezos_events_on_receiver_id"
    t.index ["related_block_id"], name: "index_tezos_events_on_related_block_id"
    t.index ["sender_id"], name: "index_tezos_events_on_sender_id"
  end

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
    t.integer "quorum"
    t.jsonb "voting_power"
    t.integer "total_rolls"
    t.integer "total_voters"
    t.integer "blocks_to_sync", default: [], array: true
    t.boolean "all_blocks_synced", default: false
    t.boolean "voting_processed", default: false
    t.integer "start_position"
    t.integer "end_position"
    t.index ["chain_id"], name: "index_tezos_voting_proposals_on_chain_id"
  end

  add_foreign_key "tezos_bakers", "tezos_chains", column: "chain_id", on_delete: :cascade
  add_foreign_key "tezos_ballots", "tezos_bakers", column: "baker_id", on_delete: :cascade
  add_foreign_key "tezos_ballots", "tezos_chains", column: "chain_id", on_delete: :cascade
  add_foreign_key "tezos_ballots", "tezos_proposals", column: "proposal_id", on_delete: :cascade
  add_foreign_key "tezos_ballots", "tezos_voting_periods", column: "voting_period_id", on_delete: :cascade
  add_foreign_key "tezos_blocks", "tezos_bakers", column: "baker_id", on_delete: :nullify
  add_foreign_key "tezos_blocks", "tezos_bakers", column: "intended_baker_id", on_delete: :nullify
  add_foreign_key "tezos_blocks", "tezos_cycles", column: "cycle_id", on_delete: :cascade
  add_foreign_key "tezos_cycles", "tezos_blocks", column: "snapshot_id", on_delete: :nullify
  add_foreign_key "tezos_cycles", "tezos_chains", column: "chain_id", on_delete: :cascade
  add_foreign_key "tezos_events", "tezos_bakers", column: "receiver_id"
  add_foreign_key "tezos_events", "tezos_bakers", column: "sender_id"
  add_foreign_key "tezos_events", "tezos_blocks", column: "block_id"
  add_foreign_key "tezos_events", "tezos_blocks", column: "related_block_id"
  add_foreign_key "tezos_proposals", "tezos_chains", column: "chain_id", on_delete: :cascade
  add_foreign_key "tezos_voting_periods", "tezos_chains", column: "chain_id", on_delete: :cascade

  create_view "tezos_endorsed_blocks", sql_definition: <<-SQL
      SELECT tezos_blocks.id,
      tezos_blocks.cycle_id,
      tezos_blocks.baker_id,
      tezos_blocks.baker_priority,
      tezos_blocks.id_hash,
      tezos_blocks.intended_baker_id,
      tezos_blocks.endorsers,
      tezos_blocks."timestamp",
      next_block.endorsed_slots
     FROM (tezos_blocks
       JOIN tezos_blocks next_block ON ((next_block.id = (tezos_blocks.id + 1))));
  SQL
end
