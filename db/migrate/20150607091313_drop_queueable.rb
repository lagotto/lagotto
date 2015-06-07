class DropQueueable < ActiveRecord::Migration
  def up
    remove_column :agents, :queueable
    drop_table :tasks
    remove_column :api_responses, :task_id
  end

  def down
    add_column :agents, :queueable, :boolean, default: true
    create_table "tasks", :force => true do |t|
      t.integer  "agent_id",                                         :null => false
      t.integer  "work_id"
      t.integer  "publisher_id"
      t.text     "config"
      t.datetime "queued_at",     :default => '1970-01-01 00:00:00', :null => false
      t.datetime "retrieved_at",  :default => '1970-01-01 00:00:00', :null => false
      t.datetime "scheduled_at",  :default => '1970-01-01 00:00:00', :null => false
      t.datetime "created_at",                                       :null => false
      t.datetime "updated_at",                                       :null => false
    end

    add_index "tasks", ["agent_id", "work_id"], :unique => true
    add_index "tasks", ["agent_id"]
    add_index "tasks", ["work_id"]

    add_column :api_responses, :task_id, :integer
  end
end
