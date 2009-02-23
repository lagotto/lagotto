class AddPublishedOnToArticle < ActiveRecord::Migration
  def self.up
    add_column :articles, :published_on, :date
  end

  def self.down
    remove_column :articles, :publihed_on
  end
end
