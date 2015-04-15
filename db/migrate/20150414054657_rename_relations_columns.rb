class RenameRelationsColumns < ActiveRecord::Migration
  def up
    add_column :relations, :level, :integer, default: 1
    rename_table :relations, :relationships
    remove_column :relation_types, :inverse_title
  end

  def down
    rename_table :relationships, :relations
    remove_column :relations, :level
    add_column :relation_types, :inverse_title, :string
  end
end
