class DropEventsTable < ActiveRecord::Migration
  def up
    remove_foreign_key "events", "sources"
    remove_foreign_key "events", "works"
    remove_foreign_key "months", "events"

    drop_table :events

    remove_column :months, :event_id

    rename_column :changes, :trace_id, :relation_id
  end

  def down
    create_table "events", force: :cascade do |t|
      t.integer  "work_id",      limit: 4,                                        null: false
      t.integer  "source_id",    limit: 4,                                        null: false
      t.datetime "retrieved_at",                  default: '1970-01-01 00:00:00', null: false
      t.integer  "total",        limit: 4,        default: 0,                     null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "events_url",   limit: 65535
      t.text     "extra",        limit: 16777215
      t.integer  "pdf",          limit: 4,        default: 0,                     null: false
      t.integer  "html",         limit: 4,        default: 0,                     null: false
      t.integer  "readers",      limit: 4,        default: 0,                     null: false
      t.integer  "comments",     limit: 4,        default: 0,                     null: false
      t.integer  "likes",        limit: 4,        default: 0,                     null: false
    end

    add_column :months, :event_id, :integer, limit: 4

    rename_column :changes, :relation_id, :trace_id

    add_index "events", ["source_id", "total", "retrieved_at"], name: "index_events_source_id_total_retrieved_at_desc"
    add_index "events", ["source_id", "total"], name: "index_events_source_id_total_desc"
    add_index "events", ["source_id", "work_id", "total"], name: "index_events_source_id_work_id_total_desc"
    add_index "events", ["source_id"], name: "index_events_on_source_id"
    add_index "events", ["source_id"], name: "index_events_on_soure_id_queued_at_scheduled_at"
    add_index "events", ["work_id", "source_id", "total"], name: "index_events_on_work_id_source_id_total"
    add_index "events", ["work_id", "source_id"], name: "index_events_on_work_id_and_source_id", unique: true
    add_index "events", ["work_id", "total"], name: "index_events_on_work_id_and_total"
    add_index "events", ["work_id"], name: "index_events_on_work_id"

    add_foreign_key "events", "sources", name: "events_source_id_fk", on_delete: :cascade
    add_foreign_key "events", "works", name: "events_work_id_fk", on_delete: :cascade
    add_foreign_key "months", "events", name: "months_event_id_fk", on_delete: :cascade
  end
end
