class ChangeArticleTitleToText < ActiveRecord::Migration
  def self.up
    change_column :articles, :title, :text
  end

  def self.down
    change_column :articles, :title, :string
  end
end
