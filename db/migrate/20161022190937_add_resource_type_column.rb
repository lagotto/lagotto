class AddResourceTypeColumn < ActiveRecord::Migration
  def change
    add_column :works, :member_id, :string, limit: 191
    add_column :works, :resource_type_id, :string, limit: 191

    add_index "works", ["member_id"], name: "works_member_id_fk"
    add_index "works", ["resource_type_id"], name: "works_resource_type_id_fk"
  end
end
