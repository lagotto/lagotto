class AddIndexesToArticles < ActiveRecord::Migration
  def up
    execute "CREATE INDEX index_articles_title_doi_published_on_article_id ON `articles` (title (255), doi (255), `published_on` DESC, id)"
    #add_index :articles, [:source_id, :event_count], :order=>{:source_id=>:asc, :event_count=>:desc}, :name => 'index_articles_title_doi_published_on_article_id'
  end

  def down
    execute "DROP INDEX index_articles_title_doi_published_on_article_id ON `articles`"
  end
end
