class AddRegistrationAgencyColumn < ActiveRecord::Migration
  def up
    Work.where("doi IS NOT NULL and registration_agency IS NULL").update_all(registration_agency: 'crossref')
  end
end
