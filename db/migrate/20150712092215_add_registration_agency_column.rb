class AddRegistrationAgencyColumn < ActiveRecord::Migration
  def up
    add_column :works, :registration_agency, :string
    add_index "works", ["registration_agency"], name: "index_works_on_registration_agency", length: 191

    Work.where("doi IS NOT NULL and registration_agency IS NULL").update_all(registration_agency: 'crossref')
  end

  def down
    remove_column :works, :registration_agency
  end
end
