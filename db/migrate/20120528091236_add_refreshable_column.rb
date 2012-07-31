class AddRefreshableColumn < ActiveRecord::Migration
  def self.up
    add_column :sources, :refreshable, :boolean, :default => true
  end

  def self.down
    remove_column :sources, :refreshable
  end
end
