class AddStatusColumn < ActiveRecord::Migration
  def up
    add_column :error_messages, :status, :integer
    add_column :error_messages, :content_type, :string
  end

  def down
    remove_column :error_messages, :status
    remove_column :error_messages, :content_type
  end
end
