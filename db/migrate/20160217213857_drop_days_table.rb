class DropDaysTable < ActiveRecord::Migration
  def up
    drop_table :days
  end

  def down
    create_table "days", force: :cascade do |t|
      t.integer  "work_id",    limit: 4,             null: false
      t.integer  "source_id",  limit: 4,             null: false
      t.integer  "event_id",   limit: 4,             null: false
      t.integer  "year",       limit: 4,             null: false
      t.integer  "month",      limit: 4,             null: false
      t.integer  "day",        limit: 4,             null: false
      t.integer  "total",      limit: 4, default: 0, null: false
      t.integer  "html",       limit: 4, default: 0, null: false
      t.integer  "pdf",        limit: 4, default: 0, null: false
      t.integer  "comments",   limit: 4, default: 0, null: false
      t.integer  "likes",      limit: 4, default: 0, null: false
      t.datetime "created_at",                       null: false
      t.datetime "updated_at",                       null: false
      t.integer  "readers",    limit: 4, default: 0, null: false
    end

    add_index "days", ["event_id", "year", "month", "day"], name: "index_days_on_event_id_and_year_and_month_and_day"
    add_index "days", ["source_id"], name: "days_source_id_fk", using: :btree
    add_index "days", ["work_id", "source_id", "year", "month"], name: "index_days_on_work_id_and_source_id_and_year_and_month"

    add_foreign_key "days", "events", name: "days_event_id_fk", on_delete: :cascade
    add_foreign_key "days", "sources", name: "days_source_id_fk", on_delete: :cascade
    add_foreign_key "days", "works", name: "days_work_id_fk", on_delete: :cascade
  end
end
