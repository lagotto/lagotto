class AddPrefixColumn < ActiveRecord::Migration
  def up
    add_column :deposits, :prefix, :string, limit: 191
    change_column :deposits, :message_type, :string, limit: 191, default: "work"

    add_index "deposits", ["prefix", "created_at"], name: "index_deposits_on_prefix_created_at"
  end

  def down
    remove_index "deposits", name: "index_deposits_on_prefix_created_at"

    remove_column :deposits, :prefix
    change_column :deposits, :message_type, :string, limit: 255, default: "default"
  end
end
