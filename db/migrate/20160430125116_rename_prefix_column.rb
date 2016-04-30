class RenamePrefixColumn < ActiveRecord::Migration
  def up
    Prefix.delete_all

    rename_column :prefixes, :prefix, :name

    remove_index "prefixes", name: "index_prefixes_on_name"
    add_index "prefixes", ["name"], name: "index_prefixes_on_name", unique: true
  end

  def down
    remove_index "prefixes", name: "index_prefixes_on_name"
    add_index "prefixes", ["name"], name: "index_prefixes_on_name"

    rename_column :prefixes, :name, :prefix
  end
end
