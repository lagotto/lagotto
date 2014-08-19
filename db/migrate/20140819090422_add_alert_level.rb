class AddAlertLevel < ActiveRecord::Migration
  def up
    rename_column :alerts, :error, :level
    change_column :alerts, :level, :integer, :default => 3
  end

  def down
    rename_column :alerts, :level, :error
    change_column :alets, :error, :boolean, :default => true
  end
end
