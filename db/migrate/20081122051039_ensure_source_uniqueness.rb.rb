class EnsureSourceUniqueness < ActiveRecord::Migration
  def self.up
    add_index :sources, :type, :unique => true
  end

  def self.down
    remove_index :sources, :type
  end
end
