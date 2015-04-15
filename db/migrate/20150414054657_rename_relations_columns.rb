class RenameRelationsColumns < ActiveRecord::Migration
  def up
    add_column :relations, :level, :integer, default: 1
    rename_table :relations, :relationships
  end

  def down
    rename_table :relationships, :relations
    remove_column :relations, :level
  end
end
