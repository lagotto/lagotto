class AddPrefixTable < ActiveRecord::Migration
  def change
    create_table :prefixes do |t|
      t.string :prefix, limit: 191
      t.string :registration_agency, limit: 191

      t.timestamps
    end

    add_index "prefixes", ["prefix"], name: "index_prefixes_on_prefix"
  end
end
