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

ActiveRecord::Schema.define(version: 20131107143459) do

  create_table "accounts", force: true do |t|
    t.string   "name",                       null: false
    t.string   "account_type",               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "balance",      default: 0.0, null: false
    t.integer  "entity_id",                  null: false
    t.integer  "parent_id"
  end

  add_index "accounts", ["parent_id"], name: "index_accounts_on_parent_id"

  create_table "budget_item_periods", force: true do |t|
    t.integer  "budget_item_id", null: false
    t.date     "start_date",     null: false
    t.decimal  "budget_amount",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "budget_item_periods", ["budget_item_id", "start_date"], name: "index_budget_item_periods_on_budget_item_id_and_start_date"

  create_table "budget_items", force: true do |t|
    t.integer  "budget_id",  null: false
    t.integer  "account_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "budget_items", ["budget_id", "account_id"], name: "index_budget_items_on_budget_id_and_account_id", unique: true

  create_table "budgets", force: true do |t|
    t.integer  "entity_id",                                 null: false
    t.string   "name",                                      null: false
    t.date     "start_date",                                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "period",       limit: 20, default: "month", null: false
    t.integer  "period_count",            default: 12,      null: false
  end

  add_index "budgets", ["entity_id"], name: "index_budgets_on_entity_id"
  add_index "budgets", ["name"], name: "index_budgets_on_name", unique: true
  add_index "budgets", ["start_date"], name: "index_budgets_on_start_date"

  create_table "entities", force: true do |t|
    t.integer  "user_id",                null: false
    t.string   "name",       limit: 100, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reconciliations", force: true do |t|
    t.integer  "account_id",          null: false
    t.date     "reconciliation_date", null: false
    t.decimal  "closing_balance",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reconciliations", ["account_id", "reconciliation_date"], name: "index_reconciliations_on_account_id_and_reconciliation_date"

  create_table "transaction_items", force: true do |t|
    t.integer  "transaction_id", null: false
    t.integer  "account_id",     null: false
    t.string   "action",         null: false
    t.decimal  "amount",         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
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

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
