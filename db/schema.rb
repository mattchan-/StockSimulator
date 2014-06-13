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

ActiveRecord::Schema.define(version: 20140613101339) do

  create_table "companies", force: true do |t|
    t.string   "name"
    t.string   "symbol"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "price"
  end

  add_index "companies", ["symbol"], name: "index_companies_on_symbol", unique: true

  create_table "dividends", force: true do |t|
    t.string   "symbol"
    t.float    "dividends"
    t.date     "ex_dividend_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
  end

  create_table "portfolios", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "cash"
  end

  create_table "positions", force: true do |t|
    t.integer  "portfolio_id"
    t.string   "symbol"
    t.integer  "shares"
    t.float    "cost_per_share"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "date_acquired"
    t.float    "price"
    t.float    "cumulative_dividends"
  end

  add_index "positions", ["portfolio_id"], name: "index_positions_on_portfolio_id"

end
