class ChangeAllowNull < ActiveRecord::Migration
  def up
    change_column :sources, :group_id, :integer, :null => false
    change_column :sources, :workers, :integer, :default => 1
    change_column :sources, :max_failed_queries, :integer, :null => false
    change_column :sources, :max_failed_query_time_interval, :integer, :null => false
    add_index :retrieval_statuses, [:id, :event_count]
    add_index :retrieval_histories, [:source_id, :event_count]
  end

  def down
    change_column :sources, :group_id, :integer, :null => true
    change_column :sources, :workers, :integer, :default => 0
    change_column :sources, :max_failed_queries, :integer, :null => true
    change_column :sources, :max_failed_query_time_interval, :integer, :null => true
    remove_index :retrieval_statuses, [:id, :event_count]
    remove_index :retrieval_histories, [:source_id, :event_count]
  end
end
