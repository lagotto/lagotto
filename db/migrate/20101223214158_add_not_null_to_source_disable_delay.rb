class AddNotNullToSourceDisableDelay < ActiveRecord::Migration
  def self.up
    change_column :sources, :disable_delay, :integer, :null => false
  end

  def self.down
    change_column :sources, :disable_delay, :integer, :null => true
  end
end
