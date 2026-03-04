# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_03_04_000002) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "aavegotchis", force: :cascade do |t|
    t.bigint "owner_id", null: false
    t.integer "base_rarity_score", null: false
    t.decimal "collateral_value", precision: 20, scale: 8, default: "0.0", null: false
    t.decimal "claimable_yield", precision: 20, scale: 8, default: "0.0", null: false
    t.jsonb "traits", default: {}
    t.integer "equipped_wearable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_aavegotchis_on_owner_id"
  end

  create_table "ledger_entries", force: :cascade do |t|
    t.bigint "transaction_id", null: false
    t.string "account", null: false
    t.decimal "debit", precision: 20, scale: 8, default: "0.0", null: false
    t.decimal "credit", precision: 20, scale: 8, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account"], name: "index_ledger_entries_on_account"
    t.index ["transaction_id"], name: "index_ledger_entries_on_transaction_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "side", null: false
    t.string "order_type", null: false
    t.decimal "price", precision: 20, scale: 8
    t.decimal "amount", precision: 20, scale: 8, null: false
    t.decimal "filled_amount", precision: 20, scale: 8, default: "0.0", null: false
    t.string "status", default: "open", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["side", "price"], name: "index_orders_on_side_and_price"
    t.index ["status", "side", "created_at"], name: "index_orders_on_status_and_side_and_created_at"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "trades", force: :cascade do |t|
    t.bigint "taker_order_id", null: false
    t.bigint "maker_order_id", null: false
    t.bigint "buyer_id", null: false
    t.bigint "seller_id", null: false
    t.decimal "price", precision: 20, scale: 8, null: false
    t.decimal "amount", precision: 20, scale: 8, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["buyer_id"], name: "index_trades_on_buyer_id"
    t.index ["created_at"], name: "index_trades_on_created_at"
    t.index ["maker_order_id"], name: "index_trades_on_maker_order_id"
    t.index ["seller_id"], name: "index_trades_on_seller_id"
    t.index ["taker_order_id"], name: "index_trades_on_taker_order_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "aavegotchi_id", null: false
    t.integer "action_type", null: false
    t.decimal "amount", precision: 20, scale: 8, default: "0.0"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["aavegotchi_id"], name: "index_transactions_on_aavegotchi_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "wallets", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token_type", default: "ghst", null: false
    t.decimal "balance", precision: 20, scale: 8, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "token_type"], name: "index_wallets_on_user_id_and_token_type", unique: true
    t.index ["user_id"], name: "index_wallets_on_user_id"
  end

  add_foreign_key "aavegotchis", "users", column: "owner_id"
  add_foreign_key "ledger_entries", "transactions"
  add_foreign_key "orders", "users"
  add_foreign_key "trades", "orders", column: "maker_order_id"
  add_foreign_key "trades", "orders", column: "taker_order_id"
  add_foreign_key "trades", "users", column: "buyer_id"
  add_foreign_key "trades", "users", column: "seller_id"
  add_foreign_key "transactions", "aavegotchis"
  add_foreign_key "wallets", "users"
end
