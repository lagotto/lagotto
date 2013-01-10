class AddDeletedColumn < ActiveRecord::Migration
  def up
    add_column :error_messages, :unresolved, :boolean, :default => 1
    add_index :error_messages, :unresolved
  end

  def down
    remove_column :error_messages, :unresolved
    remove_index :error_messages, :unresolved
  end
end
