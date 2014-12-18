class AddWorksDoiIndex < ActiveRecord::Migration
  def up
    add_index "works", ["doi", "published_on", "id"], name: "index_articles_doi_published_on_article_id"
    add_index "works", ["doi"], name: "index_works_on_doi", unique: true
  end

  def down
    remove_index "works", name: "index_articles_doi_published_on_article_id"
    remove_index "works", name: "index_works_on_doi"
  end
end
