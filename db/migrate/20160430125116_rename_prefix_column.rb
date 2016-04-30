class RenamePrefixColumn < ActiveRecord::Migration
  def up
    Prefix.delete_all

    rename_column :prefixes, :prefix, :name

    remove_index "prefixes", name: "index_prefixes_on_name"
    add_index "prefixes", ["name"], name: "index_prefixes_on_name", unique: true

    Contributor.delete_all

    remove_index "contributors", name: "index_contributors_on_orcid"
    add_index "contributors", ["orcid"], name: "index_contributors_on_orcid", unique: true

    remove_index "contributors", name: "index_contributors_on_pid"
    add_index "contributors", ["pid"], name: "index_contributors_on_pid", unique: true

    add_index "contributors", ["github"], name: "index_contributors_on_github", unique: true
  end

  def down
    remove_index "prefixes", name: "index_prefixes_on_name"
    add_index "prefixes", ["name"], name: "index_prefixes_on_name"

    rename_column :prefixes, :name, :prefix

    remove_index "contributors", name: "index_contributors_on_orcid"
    add_index "contributors", ["orcid"], name: "index_contributors_on_orcid"

    remove_index "contributors", name: "index_contributors_on_pid"
    add_index "contributors", ["pid"], name: "index_contributors_on_pid"

    remove_index "contributors", name: "index_contributors_on_github"
  end
end
