class AddArkIdentifierColumn < ActiveRecord::Migration
  def up
    add_column :works, :ark, :string

    add_index "works", ["ark", "published_on", "id"], name: "index_works_on_ark_published_on_id"
    add_index "works", ["ark"], name: "index_works_on_ark", unique: true
  end

  def down
    remove_column :works, :ark

    remove_index "works", name: "index_works_on_ark_published_on_id"
  end
end
