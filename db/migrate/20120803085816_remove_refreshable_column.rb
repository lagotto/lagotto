class RemoveRefreshableColumn < ActiveRecord::Migration
  def self.up
    remove_column :sources, :refreshable
  end
  
  def self.down
    add_column :sources, :refreshable, :boolean, :default => true
  end
end