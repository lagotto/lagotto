class RenameDisableColumn < ActiveRecord::Migration
  def up
    rename_column :sources, :disabled_until, :run_at
    add_column :sources, :state, :integer, default: 0
    add_column :sources, :queueable, :boolean, default: true
    add_column :sources, :queue, :string
    remove_column :sources, :active
  end

  def down
    rename_column :sources, :run_at, :disabled_until
    remove_column :sources, :state
    remove_column :sources, :queueable
    remove_column :sources, :queue
    add_column :sources, :active, :boolean, default: false
  end
end
