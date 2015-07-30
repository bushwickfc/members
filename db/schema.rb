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

ActiveRecord::Schema.define(version: 20150730212740) do

  create_table "committees", force: true do |t|
    t.integer  "member_id",  null: false
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "committees", ["member_id"], name: "index_committees_on_member_id", using: :btree
  add_index "committees", ["name"], name: "index_committees_on_name", unique: true, using: :btree

  create_table "events", force: true do |t|
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.string   "data",           limit: 2048
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "events", ["trackable_id", "trackable_type"], name: "index_events_on_trackable_id_and_trackable_type", using: :btree

  create_table "fees", force: true do |t|
    t.integer  "member_id",                 null: false
    t.integer  "creator_id",                null: false
    t.float    "amount",         limit: 24, null: false
    t.date     "payment_date",              null: false
    t.string   "payment_type",              null: false
    t.string   "payment_method",            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fees", ["creator_id"], name: "index_fees_on_creator_id", using: :btree
  add_index "fees", ["member_id"], name: "index_fees_on_member_id", using: :btree
  add_index "fees", ["payment_date"], name: "index_fees_on_payment_date", using: :btree

  create_table "furloughs", force: true do |t|
    t.integer  "member_id",  null: false
    t.integer  "creator_id", null: false
    t.string   "type",       null: false
    t.date     "start",      null: false
    t.date     "finish",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "furloughs", ["creator_id"], name: "index_furloughs_on_creator_id", using: :btree
  add_index "furloughs", ["member_id"], name: "index_furloughs_on_member_id", using: :btree
  add_index "furloughs", ["start", "finish"], name: "index_furloughs_on_start_and_finish", using: :btree

  create_table "members", force: true do |t|
    t.string   "first_name",                                             null: false
    t.string   "last_name",                                              null: false
    t.string   "email"
    t.string   "phone"
    t.string   "phone2"
    t.string   "fax"
    t.string   "address"
    t.string   "address2"
    t.string   "city",                              default: "Brooklyn"
    t.string   "state",                             default: "NY"
    t.string   "country",                           default: "US"
    t.string   "zip"
    t.string   "contact_preference",                default: "email"
    t.string   "gender"
    t.string   "status"
    t.date     "join_date"
    t.date     "work_date"
    t.date     "date_of_birth"
    t.boolean  "admin",                             default: false
    t.boolean  "membership_agreement",              default: false
    t.boolean  "opt_out",                           default: false
    t.float    "monthly_hours",          limit: 24, default: 4.0
    t.float    "membership_discount",    limit: 24, default: 0.0
    t.float    "annual_discount",        limit: 24, default: 0.0
    t.string   "encrypted_password",                default: "",         null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     default: 0,          null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "last_suspended_email"
  end

  add_index "members", ["admin"], name: "index_members_on_admin", using: :btree
  add_index "members", ["email"], name: "index_members_on_email", using: :btree
  add_index "members", ["first_name", "last_name"], name: "index_members_on_first_name_and_last_name", unique: true, using: :btree
  add_index "members", ["join_date"], name: "index_members_on_join_date", using: :btree
  add_index "members", ["opt_out"], name: "index_members_on_opt_out", using: :btree
  add_index "members", ["reset_password_token"], name: "index_members_on_reset_password_token", unique: true, using: :btree
  add_index "members", ["status"], name: "index_members_on_status", using: :btree
  add_index "members", ["work_date"], name: "index_members_on_work_date", using: :btree

  create_table "notes", force: true do |t|
    t.integer  "creator_id",       null: false
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.text     "note",             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notes", ["commentable_id", "commentable_type"], name: "index_notes_on_commentable_id_and_commentable_type", using: :btree
  add_index "notes", ["creator_id"], name: "index_notes_on_creator_id", using: :btree

  create_table "time_banks", force: true do |t|
    t.integer  "member_id",                                             null: false
    t.integer  "admin_id",                                              null: false
    t.integer  "committee_id"
    t.datetime "start",                                                 null: false
    t.datetime "finish",                                                null: false
    t.datetime "date_worked",                                           null: false
    t.decimal  "hours_worked", precision: 10, scale: 0, default: 0,     null: false
    t.string   "time_type",                                             null: false
    t.boolean  "approved",                              default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "time_banks", ["admin_id"], name: "index_time_banks_on_admin_id", using: :btree
  add_index "time_banks", ["committee_id"], name: "index_time_banks_on_committee_id", using: :btree
  add_index "time_banks", ["date_worked"], name: "index_time_banks_on_date_worked", using: :btree
  add_index "time_banks", ["member_id"], name: "index_time_banks_on_member_id", using: :btree
  add_index "time_banks", ["start", "finish"], name: "index_time_banks_on_start_and_finish", using: :btree

end
