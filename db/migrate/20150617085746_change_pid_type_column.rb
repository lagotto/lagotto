class ChangePidTypeColumn < ActiveRecord::Migration
  def up
    change_column :works, :pid_type, :string, default: "url"
  end

  def down
    change_column :works, :pid_type, :text
  end
end
