class IncreaseExtraColumnSize < ActiveRecord::Migration
  def up
    change_column :retrieval_statuses, :extra, :text, :limit => 64.kilobytes + 1
    change_column :alerts, :details, :text, :limit => 64.kilobytes + 1
  end

  def down
    change_column :retrieval_statuses, :extra, :text
    change_column :alerts, :details, :text
  end
end
