class AddRegistrationAgencyForDeposits < ActiveRecord::Migration
  def up
    add_column :deposits, :registration_agency_id, :string, limit: 191

    add_index "deposits", ["registration_agency_id"], name: "index_deposits_on_registration_agency_id"
  end

  def down
    remove_column :deposits, :registration_agency_id
  end
end
