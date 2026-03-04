# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record.
ActiveRecord::Schema[7.2].define(version: 2025_03_03_000005) do
  create_table "aavegotchis", force: :cascade do |t|
    t.bigint "owner_id", null: false
    t.integer "base_rarity_score", null: false
    t.decimal "collateral_value", precision: 20, scale: 8, default: "0.0", null: false
    t.decimal "claimable_yield", precision: 20, scale: 8, default: "0.0", null: false
    t.jsonb "traits", default: {}
    t.integer "equipped_wearable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ledger_entries", force: :cascade do |t|
    t.bigint "transaction_id", null: false
    t.string "account", null: false
    t.decimal "debit", precision: 20, scale: 8, default: "0.0", null: false
    t.decimal "credit", precision: 20, scale: 8, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "aavegotchi_id", null: false
    t.integer "action_type", null: false
    t.decimal "amount", precision: 20, scale: 8, default: "0.0"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "wallets", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token_type", null: false, default: "ghst"
    t.decimal "balance", precision: 20, scale: 8, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "aavegotchis", "users", column: "owner_id"
  add_foreign_key "ledger_entries", "transactions"
  add_foreign_key "transactions", "aavegotchis"
  add_foreign_key "wallets", "users"
end
