class AddTrackedColumn < ActiveRecord::Migration
  def up
    add_column :works, :tracked, :boolean, default: true
    remove_column :works, :response_id
    rename_column :retrieval_statuses, :other, :extra
  end

  def down
    remove_column :works, :tracked
    add_column :works, :response_id, :integer
    rename_column :retrieval_statuses, :extra, :other
  end
end
