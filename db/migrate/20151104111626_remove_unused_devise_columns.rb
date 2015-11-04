class RemoveUnusedDeviseColumns < ActiveRecord::Migration
  def up
    remove_column :users, "encrypted_password"
    remove_column :users, "reset_password_token"
    remove_column :users, "reset_password_sent_at"
    remove_column :users, "remember_created_at"
    remove_column :users, "sign_in_count"
    remove_column :users, "current_sign_in_at"
    remove_column :users, "last_sign_in_at"
    remove_column :users, "current_sign_in_ip"
    remove_column :users, "last_sign_in_ip"
    remove_column :users, "password_salt"
  end

  def down
    add_column :users, "encrypted_password",     :string, limit: 255, default: "", null: false
    add_column :users, "reset_password_token",   :string, limit: 191
    add_column :users, "reset_password_sent_at", :datetime
    add_column :users, "remember_created_at",    :datetime
    add_column :users, "sign_in_count",          :integer, limit: 4,   default: 0
    add_column :users, "current_sign_in_at",     :datetime
    add_column :users, "last_sign_in_at",        :datetime
    add_column :users, "current_sign_in_ip",     :string, limit: 255
    add_column :users, "last_sign_in_ip",        :string, limit: 255
    add_column :users, "password_salt",          :string, limit: 255
  end
end
