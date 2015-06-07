class RenameRetrievalStatusesTable < ActiveRecord::Migration
  def up
    rename_table :retrieval_statuses, :events
    remove_column :events, :queued_at
    remove_column :events, :scheduled_at
  end

  def down
    rename_table :events, :retrieval_statuses
    add_column :retrieval_statuses, :queued_at, :datetime
    add_column :retrieval_statuses, :scheduled_at, :datetime
  end
end
