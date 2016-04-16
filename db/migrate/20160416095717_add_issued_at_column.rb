class AddIssuedAtColumn < ActiveRecord::Migration
  def up
    add_column :works, :issued_at, :datetime, default: '1970-01-01 00:00:00', null: false
    add_column :works, :handle_url, :text, limit: 65535

    add_index "works", ["issued_at"], name: "index_on_issued_at"
  end

  def down
    remove_column :works, :issued_at
    remove_column :works, :handle_url
  end
end
