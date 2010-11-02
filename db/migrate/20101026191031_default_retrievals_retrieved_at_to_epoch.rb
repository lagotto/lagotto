class DefaultRetrievalsRetrievedAtToEpoch < ActiveRecord::Migration
  def self.up
    change_column :retrievals, :retrieved_at, :datetime, :default => '1970-01-01 00:00:00'
    Retrieval.update_all "retrieved_at = '1970-01-01 00:00:00'", "retrieved_at IS NULL"
    change_column :retrievals, :retrieved_at, :datetime, :null => false
  end

  def self.down
    change_column :retrievals, :retrieved_at, :datetime, :null => true
    Retrieval.update_all "retrieved_at = NULL", "retrieved_at = '1970-01-01 00:00:00'"
    change_column :retrievals, :retrieved_at, :datetime, :default => nil
  end
end
