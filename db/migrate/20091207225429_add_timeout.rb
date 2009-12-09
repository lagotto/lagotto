class AddTimeout < ActiveRecord::Migration
  def self.up
    add_column :sources, :timeout, :int, { :null => false, :default => 30 }
  end

  def self.down
    remove_column :sources, :timeout
  end
end
