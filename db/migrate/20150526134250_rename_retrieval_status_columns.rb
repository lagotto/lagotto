class RenameRetrievalStatusColumns < ActiveRecord::Migration
  def up
    rename_column :months, :retrieval_status_id, :event_id
    rename_column :days, :retrieval_status_id, :event_id
  end

  def down
    rename_column :months, :event_id, :retrieval_status_id
    rename_column :days, :event_id, :retrieval_status_id
  end
end
