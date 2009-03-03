class AddArticleTitle < ActiveRecord::Migration
  def self.up
    add_column :articles, :title, :string
  end

  def self.down
    remove_column :articles, :title
  end
end
