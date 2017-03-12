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

ActiveRecord::Schema.define(version: 20170210074329) do

  create_table "data_migrations", force: :cascade do |t|
    t.string "version", limit: 191
  end

  create_table "events", force: :cascade do |t|
    t.text     "uuid",             limit: 65535,                                 null: false
    t.string   "subj_id",          limit: 191,                                   null: false
    t.string   "obj_id",           limit: 191
    t.string   "source_id",        limit: 191
    t.integer  "state",            limit: 4,     default: 0
    t.string   "state_event",      limit: 255
    t.text     "callback",         limit: 65535
    t.text     "error_messages",   limit: 65535
    t.text     "source_token",     limit: 65535
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.datetime "indexed_at",                     default: '1970-01-01 00:00:00', null: false
    t.datetime "occurred_at"
    t.string   "message_action",   limit: 191,   default: "create",              null: false
    t.string   "relation_type_id", limit: 191
    t.text     "subj",             limit: 65535
    t.text     "obj",              limit: 65535
    t.integer  "total",            limit: 4,     default: 1
  end

  add_index "events", ["source_id", "created_at"], name: "index_events_on_source_id_created_at", using: :btree
  add_index "events", ["subj_id"], name: "index_events_on_subj_id", using: :btree
  add_index "events", ["updated_at"], name: "index_events_on_updated_at", using: :btree

  create_table "metadata", force: :cascade do |t|
    t.integer  "work_id",        limit: 4,                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version",        limit: 4,     default: 0
    t.string   "schema_version", limit: 191
    t.binary   "xml",            limit: 65535
  end

  add_index "metadata", ["work_id", "version"], name: "index_metadata_on_work_id", using: :btree

  create_table "providers", force: :cascade do |t|
    t.string   "name",       limit: 191
    t.string   "title",      limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "providers", ["name"], name: "index_providers_on_name", unique: true, using: :btree

  create_table "sources", force: :cascade do |t|
    t.string   "name",        limit: 191
    t.string   "title",       limit: 255,                   null: false
    t.string   "group_id",    limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description", limit: 65535
    t.boolean  "private",                   default: false
    t.boolean  "cumulative",                default: false
  end

  add_index "sources", ["name"], name: "index_sources_on_name", unique: true, using: :btree

  create_table "works", force: :cascade do |t|
    t.text     "pid",         limit: 65535,                                 null: false
    t.string   "provider_id", limit: 191,                                   null: false
    t.boolean  "indexed",                   default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "indexed_at",                default: '1970-01-01 00:00:00', null: false
  end

  add_index "works", ["pid"], name: "index_works_on_pid", unique: true, length: {"pid"=>191}, using: :btree
  add_index "works", ["provider_id"], name: "index_on_provider_id", using: :btree
  add_index "works", ["updated_at"], name: "index_on_updated_at", using: :btree

end
