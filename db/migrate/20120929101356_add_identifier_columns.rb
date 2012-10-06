class AddIdentifierColumns < ActiveRecord::Migration
  def up
    add_column :articles, :url, :string
    add_column :articles, :mendeley, :string
  end

  def down
    remove_column :articles, :url
    remove_column :articles, :mendeley
  end
end
