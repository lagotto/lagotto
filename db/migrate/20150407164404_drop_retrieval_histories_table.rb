class DropRetrievalHistoriesTable < ActiveRecord::Migration
  def up
    drop_table :retrieval_histories
  end

  def down
    create_table "retrieval_histories", force: :cascade do |t|
      t.integer  "retrieval_status_id", limit: 4,               null: false
      t.integer  "work_id",             limit: 4,               null: false
      t.integer  "source_id",           limit: 4,               null: false
      t.datetime "retrieved_at"
      t.string   "status",              limit: 255
      t.string   "msg",                 limit: 255
      t.integer  "event_count",         limit: 4,   default: 0
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "retrieval_histories", ["retrieval_status_id", "retrieved_at"], name: "index_rh_on_id_and_retrieved_at", using: :btree
    add_index "retrieval_histories", ["source_id", "status", "updated_at"], name: "index_retrieval_histories_on_source_id_and_status_and_updated", using: :btree
  end
end
