class RenameDisableColumn < ActiveRecord::Migration
  def up
    rename_column :sources, :disabled_until, :run_at
    add_column :sources, :queued, :boolean, default: 1
  end

  def down
    rename_column :sources, :run_at, :disabled_until
    remove_column :sources, :queued
  end
end
