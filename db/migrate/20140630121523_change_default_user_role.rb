class ChangeDefaultUserRole < ActiveRecord::Migration
  def up
    change_column :users, :role, :string, default: "anonymous"
  end

  def down
    change_column :users, :role, :string, default: "user"
  end
end
