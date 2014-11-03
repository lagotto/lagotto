class SetDefaultRetrievedAtOnRetrievalHistories < ActiveRecord::Migration
  def change
    change_column :retrieval_statuses, :retrieved_at, :datetime, :default => '1970-01-01 00:00:00', :null=>false
  end
end
