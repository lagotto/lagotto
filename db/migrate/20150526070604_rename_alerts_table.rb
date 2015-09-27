class RenameAlertsTable < ActiveRecord::Migration
  def up
    rename_table :alerts, :notifications
  end

  def down
    rename_table :notifications, :alerts
  end
end
