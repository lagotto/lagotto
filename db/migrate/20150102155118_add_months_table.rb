class AddMonthsTable < ActiveRecord::Migration
  def up
    create_table "months", force: true do |t|
      t.integer  "work_id",                    null: false
      t.integer  "source_id",                  null: false
      t.integer  "retrieval_status_id",        null: false
      t.integer  "year",                       null: false
      t.integer  "month",                      null: false
      t.integer  "total_count",    default: 0, null: false
      t.integer  "html_count"
      t.integer  "pdf_count"
      t.integer  "comments_count"
      t.integer  "likes_count"
      t.datetime "created_at",                 null: false
      t.datetime "updated_at",                 null: false
    end

    create_table "days", force: true do |t|
      t.integer  "work_id",                    null: false
      t.integer  "source_id",                  null: false
      t.integer  "retrieval_status_id",        null: false
      t.integer  "year",                       null: false
      t.integer  "month",                      null: false
      t.integer  "day",                      null: false
      t.integer  "total_count",    default: 0, null: false
      t.integer  "html_count"
      t.integer  "pdf_count"
      t.integer  "comments_count"
      t.integer  "likes_count"
      t.datetime "created_at",                 null: false
      t.datetime "updated_at",                 null: false
    end

    add_index "months", ["work_id", "source_id", "year", "month"], name: "index_months_on_work_id_and_source_id_and_year_and_month"
    add_index "days", ["work_id", "source_id", "year", "month"], name: "index_days_on_work_id_and_source_id_and_year_and_month"
  end

  def down
    drop_table :months
    drop_table :days
  end
end
