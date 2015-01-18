class AddStatusTable < ActiveRecord::Migration
  def up
    create_table "status", :force => true do |t|
      t.integer  "works_count",                     default: 0
      t.integer  "works_new_count",                 default: 0
      t.integer  "events_count",                    default: 0
      t.integer  "responses_count",                 default: 0
      t.integer  "requests_count",                  default: 0
      t.integer  "requests_average",                default: 0
      t.integer  "alerts_count",                    default: 0
      t.integer  "sources_working_count",           default: 0
      t.integer  "sources_waiting_count",           default: 0
      t.integer  "sources_disabled_count",          default: 0
      t.integer  "db_size",                         default: 0
      t.string  "version"
      t.string  "current_version"
      t.datetime "created_at",                      null: false
      t.datetime "updated_at",                      null: false
    end

    add_index "status", ["created_at"], name: "index_status_created_at"
  end

  def down
    drop_table :status
  end
end
