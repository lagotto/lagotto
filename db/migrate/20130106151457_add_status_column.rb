class AddStatusColumn < ActiveRecord::Migration
  def up
    add_column :error_messages, :status_code, :integer
  end

  def down
    remove_column :error_messages, :status_code
  end
end
