class AddSourceColumn < ActiveRecord::Migration
  def up
    add_column :error_messages, :source_id, :integer
    add_index :error_messages, :source_id
    add_index :error_messages, :updated_at
  end

  def down
    remove_column :error_messages, :source_id
    remove_index :error_messages, :source_id
    remove_index :error_messages, :updated_at
  end

end
