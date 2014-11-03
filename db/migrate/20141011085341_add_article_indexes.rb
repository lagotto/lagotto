class AddArticleIndexes < ActiveRecord::Migration
  def up
    add_index :articles, [:published_on]
    add_index :articles, [:publisher_id, :published_on]
  end

  def down
    remove_index :articles, [:published_on]
    remove_index :articles, [:publisher_id, :published_on]
  end
end
