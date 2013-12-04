class AddIndexesToArticles < ActiveRecord::Migration
  def up
    #Can't use ruby create index syntax here as it doesn't support field sizes
    execute "CREATE INDEX index_articles_title_doi_published_on_article_id ON `articles` (title (255), doi (255), `published_on` DESC, id)"
  end

  def down
    execute "DROP INDEX index_articles_title_doi_published_on_article_id ON `articles`"
  end
end
