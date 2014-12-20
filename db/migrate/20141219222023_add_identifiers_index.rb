class AddIdentifiersIndex < ActiveRecord::Migration
  def up
    # add_index "works", ["pmid", "published_on", "id"], name: "index_works_on_pmid_published_on_id"
    # add_index "works", ["pmid"], name: "index_works_on_pmid", unique: true
    # add_index "works", ["pmcid", "published_on", "id"], name: "index_works_on_pmcid_published_on_id"
    # add_index "works", ["pmcid"], name: "index_works_on_pmcid", unique: true
    add_index "works", ["canonical_url", "published_on", "id"], name: "index_works_on_url_published_on_id", length: { "canonical_url" => 50 }
    add_index "works", ["canonical_url"], name: "index_works_on_url", length: 50, unique: true
  end

  def down
    remove_index "works", name: "index_works_on_pmid_published_on_id"
    remove_index "works", name: "index_works_on_pmid"
    remove_index "works", name: "index_works_on_pmcid_published_on_id"
    remove_index "works", name: "index_works_on_pmcid"
    remove_index "works", name: "index_works_on_url_published_on_id"
    remove_index "works", name: "index_works_on_url"
  end
end
