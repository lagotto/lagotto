class ChangePublisherColumn < ActiveRecord::Migration
  def up
    remove_foreign_key :publisher_options, name: "publisher_options_publisher_id_fk"
    add_foreign_key "publisher_options", "publishers", name: "publisher_options_publisher_id_fk", on_delete: :cascade

    rename_column :publishers, :service, :registration_agency
    change_column :publishers, :name, :string, limit: 191
    change_column :publishers, :registration_agency, :string, limit: 191
    remove_column :publishers, :member_id, :integer
    remove_column :publishers, :member_symbol, :string, limit: 191
    remove_column :publishers, :symbol, :string
    add_column :publishers, :active, :boolean, default: false

    add_index :publishers, ["name"], name: "index_publishers_on_name"
    add_index :publishers, ["registration_agency"], name: "index_publishers_on_registration_agency"
  end

  def down
    change_column :publishers, :name, :string, limit: 255
    add_column :publishers, :member_id, :integer
    add_column :publishers, :member_symbol, :string, limit: 191
    add_column :publishers, :symbol, :string
    remove_column :publishers, :active

    remove_index :publishers, name: "index_publishers_on_registration_agency"
    rename_column :publishers, :registration_agency, :service

    remove_index :publishers, name: "index_publishers_on_name"
    add_index :publishers, ["member_id"], name: "index_publishers_on_member_id", unique: true
    add_index :publishers, ["member_symbol"], name: "index_publishers_on_member_symbol"

    remove_foreign_key :publisher_options, name: "publisher_options_publisher_id_fk"
    add_foreign_key "publisher_options", "publishers", primary_key: "member_id", name: "publisher_options_publisher_id_fk", on_delete: :cascade
  end
end
