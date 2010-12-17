class ChangeDefaultDisableDelay < ActiveRecord::Migration
  def self.up
    change_column :sources, :disable_delay, :int, :default => 10
  end

  def self.down
    change_column :sources, :disable_delay, :int, :default => 900
  end
end
