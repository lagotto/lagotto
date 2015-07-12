class AddRegistrationAgencyColumn < ActiveRecord::Migration
  def up
    add_column :works, :registration_agency, :string
    add_index "works", ["registration_agency"], name: "index_works_on_registration_agency"
  end

  def down
    remove_column :works, :registration_agency
  end
end
