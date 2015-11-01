class DropEmailIndex < ActiveRecord::Migration
  def up
    change_column :users, :uid, :string, limit: 191
    add_index :users, ["uid"], name: "index_users_on_uid", unique: true
    remove_index :users, name: "index_users_on_email", unique: true, column: :email
  end

  def down
    remove_index :users, name: "index_users_on_uid"
    add_index :users, ['email'], name: "index_users_on_email", unique: true
  end
end
