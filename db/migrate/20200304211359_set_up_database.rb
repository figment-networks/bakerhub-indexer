class SetUpDatabase < ActiveRecord::Migration[6.0]
  def change
    create_table "tezos_bakers", id: :string, force: :cascade do |t|
      t.bigint "chain_id", null: false
      t.string "name"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.string "url"
      t.index ["chain_id"], name: "index_tezos_bakers_on_chain_id"
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
      t.index ["chain_id"], name: "index_tezos_cycles_on_chain_id"
      t.index ["snapshot_id"], name: "index_tezos_cycles_on_snapshot_id"
    end

    create_table "tezos_missed_bakes", force: :cascade do |t|
      t.string "baker_id", null: false
      t.bigint "block_id", null: false
      t.integer "priority"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["baker_id"], name: "index_tezos_missed_bakes_on_baker_id"
      t.index ["block_id"], name: "index_tezos_missed_bakes_on_block_id"
    end

    add_foreign_key "tezos_bakers", "tezos_chains", column: "chain_id", on_delete: :cascade
    add_foreign_key "tezos_blocks", "tezos_bakers", column: "baker_id", on_delete: :nullify
    add_foreign_key "tezos_blocks", "tezos_bakers", column: "intended_baker_id", on_delete: :nullify
    add_foreign_key "tezos_blocks", "tezos_cycles", column: "cycle_id", on_delete: :cascade
    add_foreign_key "tezos_cycles", "tezos_blocks", column: "snapshot_id", on_delete: :nullify
    add_foreign_key "tezos_cycles", "tezos_chains", column: "chain_id", on_delete: :cascade
    add_foreign_key "tezos_missed_bakes", "tezos_bakers", column: "baker_id", on_delete: :cascade
    add_foreign_key "tezos_missed_bakes", "tezos_blocks", column: "block_id", on_delete: :cascade

    create_view :tezos_endorsed_blocks
  end
end
