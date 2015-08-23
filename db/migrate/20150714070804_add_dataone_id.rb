class AddDataoneId < ActiveRecord::Migration
  def change
    add_column :works, :dataone, :string, limit: 191
    add_index "works", ["dataone"], name: "index_works_on_dataone", unique: true
  end
end
