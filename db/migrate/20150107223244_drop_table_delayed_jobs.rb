class DropTableDelayedJobs < ActiveRecord::Migration
  def up
    drop_table :delayed_jobs
  end

  def down
    create_table "delayed_jobs", force: :cascade do |t|
      t.integer  "priority",   limit: 4,        default: 0
      t.integer  "attempts",   limit: 4,        default: 0
      t.text     "handler",    limit: 16777215
      t.text     "last_error", limit: 65535
      t.datetime "run_at"
      t.datetime "locked_at"
      t.datetime "failed_at"
      t.string   "locked_by",  limit: 255
      t.string   "queue",      limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "delayed_jobs", ["locked_at", "locked_by", "failed_at"], name: "index_delayed_jobs_locked_at_locked_by_failed_at"
    add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"
    add_index "delayed_jobs", ["queue"], name: "index_delayed_jobs_queue"
    add_index "delayed_jobs", ["run_at", "locked_at", "locked_by", "failed_at", "priority"], name: "index_delayed_jobs_run_at_locked_at_failed_at_priority"
  end
end
