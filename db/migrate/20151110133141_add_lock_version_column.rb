class AddLockVersionColumn < ActiveRecord::Migration
  def change
    add_column :works, :lock_version, :integer, default: 0, null: false
  end
end
