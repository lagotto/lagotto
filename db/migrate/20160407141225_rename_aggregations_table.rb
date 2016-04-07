class RenameAggregationsTable < ActiveRecord::Migration
  def self.up
    rename_table :aggregations, :results
    rename_column :months, :aggregation_id, :result_id
    rename_column :status, :events_count, :results_count
  end

  def self.down
    rename_table :results, :aggregations
    rename_column :months, :result_id, :aggregation_id
    rename_column :status, :results_count, :events_count
  end
end
