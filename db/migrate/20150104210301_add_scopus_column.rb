class AddScopusColumn < ActiveRecord::Migration
  def up
    add_column :works, :scp, :string
    add_column :works, :wos, :string

    add_index "works", ["scp", "published_on", "id"], name: "index_works_on_scp_published_on_id"
    add_index "works", ["scp"], name: "index_works_on_scp", unique: true
    add_index "works", ["wos", "published_on", "id"], name: "index_works_on_wos_published_on_id"
    add_index "works", ["wos"], name: "index_works_on_wos", unique: true
  end

  def down
    remove_column :works, :scp
    remove_column :works, :wos

    remove_index "works", name: "index_works_on_scp_published_on_id"
    remove_index "works", name: "index_works_on_wos_published_on_id"
  end
end
