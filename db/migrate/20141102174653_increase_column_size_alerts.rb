class IncreaseColumnSizeAlerts < ActiveRecord::Migration
  def up
    change_column :alerts, :details, :text, :limit => 64.kilobytes + 1
  end

  def down
    change_column :alerts, :details, :text
  end
end
