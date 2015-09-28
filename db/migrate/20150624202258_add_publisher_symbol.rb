class AddPublisherSymbol < ActiveRecord::Migration
  def up
    add_column :publishers, :member_symbol, :string, limit: 191
    add_index :publishers, ["member_symbol"], name: "index_publishers_on_member_symbol"
  end

  def down
    remove_column :publishers, :member_symbol
  end
end
