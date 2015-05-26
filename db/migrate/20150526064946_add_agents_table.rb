class AddAgentsTable < ActiveRecord::Migration
  def up
    create_table "agents", :force => true do |t|
      t.string   "type",                                            :null => false
      t.string   "name",                                            :null => false
      t.string   "title",                                           :null => false
      t.string   "kind",         :default => "work"
      t.string   "source",                                          :null => false
      t.integer  "state",       limit: 4,     default: 0
      t.string   "state_event"
      t.text     "config",      limit: 65535
      t.integer  "group_id",                                        :null => false
      t.boolean  "queueable",   limit: 1,     default: true
      t.boolean  "eventable",   limit: 1,     default: true
      t.datetime "run_at",       :default => '1970-01-01 00:00:00', :null => false
      t.datetime "created_at",                                      :null => false
      t.datetime "updated_at",                                      :null => false
      t.datetime "cached_at",    :default => '1970-01-01 00:00:00', :null => false
    end

    remove_column :sources, :type
    remove_column :sources, :queueable
    remove_column :sources, :eventable
    remove_column :sources, :state_event
    remove_column :sources, :config
    remove_column :sources, :run_at
    rename_column :sources, :state, :active
    change_column :sources, :active, :boolean, default: false

    add_column :alerts, :agent_id, :integer
  end

  def down
    drop_table :agents

    add_column :sources, :type, :string, :null => false
    add_column :sources, :queueable, :boolean,    :default => true
    add_column :sources, :eventable, :boolean,    :default => true
    add_column :sources, :state_event, :string
    add_column :sources, :config, :text
    add_column :sources, :run_at, :datetime, :default => '1970-01-01 00:00:00', :null => false
    rename_column :sources, :active, :state
    change_column :sources, :state, :integer

    remove_column :alerts, :agent_id
  end
end
