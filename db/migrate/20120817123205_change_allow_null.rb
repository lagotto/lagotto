class ChangeAllowNull < ActiveRecord::Migration
  def up
    change_column :sources, :group_id, :integer, :null => false
    change_column :sources, :workers, :integer, :default => 1
    change_column :sources, :max_failed_queries, :integer, :null => false
    change_column :sources, :max_failed_query_time_interval, :integer, :null => false
  end

  def down
    change_column :sources, :group_id, :integer, :null => true
    change_column :sources, :workers, :integer, :default => 0
    change_column :sources, :max_failed_queries, :integer, :null => true
    change_column :sources, :max_failed_query_time_interval, :integer, :null => true
  end
end
