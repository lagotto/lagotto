class AddStatusesTable < ActiveRecord::Migration
  def up
    create_table "statuses", :force => true do |t|
      t.integer  "works_count",                     default: 0
      t.integer  "events_count",                    default: 0
      t.integer  "responses_count",                 default: 0
      t.integer  "requests_count",                  default: 0
      t.integer  "alerts_count",                    default: 0
      t.integer  "sources_working_count",           default: 0
      t.integer  "sources_waiting_count",           default: 0
      t.integer  "sources_disabled_count",          default: 0
      t.integer  "users_count",                     default: 0
      t.string  "version"
      t.datetime "created_at",                                       null: false
      t.datetime "updated_at",                                       null: false
    end

    add_index "statuses", ["created_at"], name: "index_statuses_created_at"
  end

  def down
    drop_table :statuses
  end
end
