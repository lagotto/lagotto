class AddRefreshedAtToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :refreshed_at, :datetime, :default => DateTime.new(1970), 
      :null => false
  end

  def self.down
    remove_column :articles, :refreshed_at
  end
end
