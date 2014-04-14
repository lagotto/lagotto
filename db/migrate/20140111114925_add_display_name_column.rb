class AddDisplayNameColumn < ActiveRecord::Migration
  def up
    add_column :groups, :display_name, :string
  end

  def down
    remove_column :groups, :display_name
  end
end
