# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150115013953) do

  # These are extensions that must be enabled in order to support this database
#  enable_extension "plpgsql"

  create_table "accounts", force: true do |t|
    t.string   "name",                                  null: false
    t.string   "account_type",                          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "balance",                 default: 0.0, null: false
    t.integer  "entity_id",                             null: false
    t.integer  "parent_id"
    t.string   "content_type", limit: 20
  end

  add_index "accounts", ["parent_id"], name: "index_accounts_on_parent_id", using: :btree

  create_table "attachment_contents", force: true do |t|
    t.binary   "data",         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "entity_id"
    t.text     "content_type", null: false
  end

  create_table "attachments", force: true do |t|
    t.integer  "transaction_id",        null: false
    t.text     "name",                  null: false
    t.text     "content_type",          null: false
    t.integer  "size",                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "attachment_content_id", null: false
  end

  add_index "attachments", ["transaction_id"], name: "index_attachments_on_transaction_id", using: :btree

  create_table "budget_item_periods", force: true do |t|
    t.integer  "budget_item_id", null: false
    t.date     "start_date",     null: false
    t.decimal  "budget_amount",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "budget_item_periods", ["budget_item_id", "start_date"], name: "index_budget_item_periods_on_budget_item_id_and_start_date", using: :btree

  create_table "budget_items", force: true do |t|
    t.integer  "budget_id",  null: false
    t.integer  "account_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "budget_items", ["budget_id", "account_id"], name: "index_budget_items_on_budget_id_and_account_id", unique: true, using: :btree

  create_table "budget_monitors", force: true do |t|
    t.integer  "entity_id",  null: false
    t.integer  "account_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "budget_monitors", ["account_id"], name: "index_budget_monitors_on_account_id", unique: true, using: :btree

  create_table "budgets", force: true do |t|
    t.integer  "entity_id",                                 null: false
    t.string   "name",                                      null: false
    t.date     "start_date",                                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "period",       limit: 20, default: "month", null: false
    t.integer  "period_count",            default: 12,      null: false
  end

  add_index "budgets", ["entity_id"], name: "index_budgets_on_entity_id", using: :btree
  add_index "budgets", ["name"], name: "index_budgets_on_name", unique: true, using: :btree
  add_index "budgets", ["start_date"], name: "index_budgets_on_start_date", using: :btree

  create_table "commodities", force: true do |t|
    t.integer  "entity_id"
    t.string   "name"
    t.string   "symbol",     limit: 5
    t.string   "market",     limit: 10
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "commodities", ["entity_id", "symbol"], name: "index_commodities_on_entity_id_and_symbol", unique: true, using: :btree

  create_table "entities", force: true do |t|
    t.integer  "user_id",                null: false
    t.string   "name",       limit: 100, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lot_transactions", force: true do |t|
    t.integer  "lot_id",                                 null: false
    t.integer  "transaction_id",                         null: false
    t.decimal  "shares_traded",  precision: 8, scale: 4, null: false
    t.decimal  "price",          precision: 8, scale: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lot_transactions", ["lot_id"], name: "index_lot_transactions_on_lot_id", using: :btree

  create_table "lots", force: true do |t|
    t.integer  "account_id",                            null: false
    t.integer  "commodity_id",                          null: false
    t.decimal  "price",         precision: 8, scale: 4, null: false
    t.decimal  "shares_owned",  precision: 8, scale: 4, null: false
    t.date     "purchase_date",                         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lots", ["account_id"], name: "index_lots_on_account_id", using: :btree

  create_table "prices", force: true do |t|
    t.integer  "commodity_id",                         null: false
    t.date     "trade_date",                           null: false
    t.decimal  "price",        precision: 8, scale: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "prices", ["commodity_id", "trade_date"], name: "index_prices_on_commodity_id_and_trade_date", unique: true, using: :btree

  create_table "reconciliation_items", force: true do |t|
    t.integer  "reconciliation_id",   null: false
    t.integer  "transaction_item_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reconciliation_items", ["reconciliation_id"], name: "index_reconciliation_items_on_reconciliation_id", using: :btree
  add_index "reconciliation_items", ["transaction_item_id"], name: "index_reconciliation_items_on_transaction_item_id", using: :btree

  create_table "reconciliations", force: true do |t|
    t.integer  "account_id",          null: false
    t.date     "reconciliation_date", null: false
    t.decimal  "closing_balance",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reconciliations", ["account_id", "reconciliation_date"], name: "index_reconciliations_on_account_id_and_reconciliation_date", using: :btree

  create_table "transaction_items", force: true do |t|
    t.integer  "transaction_id",                             null: false
    t.integer  "account_id",                                 null: false
    t.string   "action",                                     null: false
    t.decimal  "amount",                                     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "reconciled",                 default: false, null: false
    t.string   "memo",           limit: 100
    t.string   "confirmation",   limit: 50
  end

  create_table "transactions", force: true do |t|
    t.date     "transaction_date", null: false
    t.string   "description",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "entity_id",        null: false
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
