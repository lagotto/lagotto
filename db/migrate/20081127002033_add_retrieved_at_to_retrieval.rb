class AddRetrievedAtToRetrieval < ActiveRecord::Migration
  def self.up
    add_column :retrievals, :retrieved_at, :datetime
  end

  def self.down
    remove_column :retrievals, :retrieved_at
  end
end
