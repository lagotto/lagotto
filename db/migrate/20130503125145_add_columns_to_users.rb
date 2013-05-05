class AddColumnsToUsers < ActiveRecord::Migration
  def up
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    add_column :users, :name, :string
    add_column :users, :authentication_token, :string
    add_column :users, :role, :string, :default => "user"
    
    add_index :users, ["authentication_token"], :name => "index_users_authentication_token", :unique => true
    
    remove_column :users, :encrypted_password
    remove_column :users, :reset_password_token
    remove_column :users, :reset_password_sent_at
    remove_column :users, :password_salt
  end
  
  def down
    remove_column :users, :provider
    remove_column :users, :uid
    remove_column :users, :name
    remove_column :users, :authentication_token
    remove_column :users, :role
    
    add_column :users, :encrypted_password, :string, :null => false, :default => ""
    add_column :users, :reset_password_token, :string
    add_column :users, :reset_password_sent_at, :datetime
    add_column :users, :password_salt, :string
  end
end
