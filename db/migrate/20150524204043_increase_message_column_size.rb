class IncreaseMessageColumnSize < ActiveRecord::Migration
  def up
    change_column :alerts, :message, :text, :limit => 64.kilobytes + 1
  end

  def down
    change_column :alerts, :message, :text
  end
end
