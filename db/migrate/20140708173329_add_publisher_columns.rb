class AddPublisherColumns < ActiveRecord::Migration
  def up
    add_column :users, :publisher_name, :string, null: true
    add_column :users, :publisher_id, :integer, null: true
  end

  def down
    remove_column :users, :publisher_name
    remove_column :users, :publisher_id
  end
end
