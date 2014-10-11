class AddAlertIndexes < ActiveRecord::Migration
  def up
    add_index :alerts, [:created_at]
    add_index :alerts, [:level, :created_at]
    add_index :alerts, [:source_id, :created_at]
    add_index :alerts, [:class_name]
    remove_index :api_responses, name: "index_api_responses_on_created_at"
    add_index :sources, [:state]
  end

  def down
    remove_index :alerts, [:created_at]
    remove_index :alerts, [:level, :created_at]
    remove_index :alerts, [:source_id, :created_at]
    remove_index :alerts, [:class_name]
    add_index :api_responses, [:created_at], name: "index_api_responses_on_created_at"
    remove_index :sources, [:state]
  end
end
