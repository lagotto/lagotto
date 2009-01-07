class EnsureDoiUniqueness < ActiveRecord::Migration
  def self.up
    add_index :articles, :doi, :unique => true
  end

  def self.down
    remove_index :articles, :doi
  end
end
