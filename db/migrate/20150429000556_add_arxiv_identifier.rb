class AddArxivIdentifier < ActiveRecord::Migration
  def up
    add_column :works, :arxiv, :string, limit: 191
    add_index "works", ["arxiv", "published_on", "id"], name: "index_works_on_arxiv_published_on_id"
    add_index "works", ["arxiv"], name: "index_works_on_arxiv", unique: true
  end

  def down
    remove_column :works, :arxiv
    remove_index "works", name: "index_works_on_arxiv_published_on_id"
  end
end
