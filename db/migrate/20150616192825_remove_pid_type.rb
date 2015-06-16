class RemovePidType < ActiveRecord::Migration
  def up
    remove_column :works, :pid_type
  end

  def down
    add_column :works, :pid_type, :text
  end
end
