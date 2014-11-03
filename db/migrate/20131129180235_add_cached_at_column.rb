class AddCachedAtColumn < ActiveRecord::Migration
  def up
    change_column_default(:sources, :state, nil)
    add_column :sources, :cached_at, :datetime, :null => false, :default => '1970-01-01 00:00:00'
  end

  def down
    change_column_default(:sources, :state, 0)
    remove_column :sources, :cached_at
  end
end
