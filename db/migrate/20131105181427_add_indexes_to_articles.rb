class AddIndexesToArticles < ActiveRecord::Migration
  def change
    add_index :articles, [:doi, :published_on, :id], :order=>{:doi=>:asc, :published_on=>:desc, :id=>:asc}, :name => 'index_articles_doi_published_on_article_id'
  end
end