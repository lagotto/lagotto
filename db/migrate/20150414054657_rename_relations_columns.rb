class RenameRelationsColumns < ActiveRecord::Migration
  def up
    add_column :relations, :level, :integer, default: 1
    rename_table :relations, :relationships
    add_column :relation_types, :inverse, :boolean, default: false
    remove_column :relation_types, :inverse_title
  end

  def down
    rename_table :relationships, :relations
    remove_column :relations, :level
    add_column :relation_types, :inverse_title, :string
    remove_column :relation_types, :inverse
  end
end
