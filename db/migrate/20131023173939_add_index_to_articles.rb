class AddIndexToArticles < ActiveRecord::Migration
  def change

    #CREATE INDEX index_articles_published_on_desc ON `articles` (`published_on` DESC);
    add_index :articles, [:published_on], :order=>{:published_on=>:desc}, :name => 'index_articles_published_on_desc'

  end
end
