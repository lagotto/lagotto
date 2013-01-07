class AddResponseColumn < ActiveRecord::Migration
  def up
    add_column :error_messages, :response, :text
  end

  def down
    remove_column :error_messages, :response
  end
end
