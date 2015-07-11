class AddPublisherNodeSymbol < ActiveRecord::Migration
  def up
    add_column :publishers, :symbol, :string
    add_column :publishers, :url, :text
  end

  def down
    remove_column :publishers, :symbol
    remove_column :publishers, :url
  end
end
