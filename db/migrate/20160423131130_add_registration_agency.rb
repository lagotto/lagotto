class AddRegistrationAgency < ActiveRecord::Migration
  def up
    create_table :registration_agencies do |t|
      t.string :name
      t.string :title

      t.timestamps null: false
    end

    add_column :works, :registration_agency_id, :integer
    add_column :publishers, :registration_agency_id, :integer, null: false
    remove_column :publishers, :prefixes
    add_column :prefixes, :registration_agency_id, :integer, null: false
    add_column :prefixes, :publisher_id, :integer

    add_index "works", ["registration_agency_id"], name: "index_on_registration_agency_id"
  end

  def down
    remove_column :works, :registration_agency_id
    remove_column :publishers, :registration_agency_id
    add_column :publishers, :prefixes, :string
    remove_column :prefixes, :registration_agency_id
    remove_column :prefixes, :publisher_id
    drop_table :registration_agencies
  end
end
