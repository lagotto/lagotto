class RenameStatusColumns < ActiveRecord::Migration
  def up
    rename_column :status, :sources_working_count, :agents_working_count
    rename_column :status, :sources_waiting_count, :agents_waiting_count
    rename_column :status, :sources_disabled_count, :agents_disabled_count
    rename_column :status, :alerts_count, :notifications_count
  end

  def down
    rename_column :status, :agents_working_count, :sources_working_count
    rename_column :status, :agents_waiting_count, :sources_waiting_count
    rename_column :status, :agents_disabled_count, :sources_disabled_count
    rename_column :status, :notifications_count, :alerts_count
  end
end
