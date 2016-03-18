class IncreaseTargetUrlColumnSize < ActiveRecord::Migration
  def up
    change_column :notifications, :target_url, :text, limit: 65535
  end

  def down
    change_column :notifications, :target_url, :text, limit: 1000
  end
end
