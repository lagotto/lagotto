class AddColumnsToUsers < ActiveRecord::Migration
  def up
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    add_column :users, :name, :string
    add_column :users, :authentication_token, :string, limit: 191
    add_column :users, :role, :string, :default => "user"

    add_index :users, ["username"], :name => "index_users_username", :unique => true
    add_index :users, ["authentication_token"], :name => "index_users_authentication_token", :unique => true
  end

  def down
    remove_column :users, :provider
    remove_column :users, :uid
    remove_column :users, :name
    remove_column :users, :authentication_token
    remove_column :users, :role

    remove_index :users, ["username"], :name => "index_users_username"
  end
end
