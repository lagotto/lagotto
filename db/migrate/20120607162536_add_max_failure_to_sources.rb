class AddMaxFailureToSources < ActiveRecord::Migration
  def change
    add_column :sources, :max_failed_queries, :integer, :default => 200
    add_column :sources, :max_failed_query_time_interval, :integer, :default => 86400   # time in seconds
    add_index :retrieval_histories, [:source_id, :status, :updated_at]
  end
end
