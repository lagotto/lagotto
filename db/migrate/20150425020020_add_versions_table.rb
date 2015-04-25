class AddVersionsTable < ActiveRecord::Migration
  def up
    rename_table :relationships, :relations
    add_column :relation_types, :level, :integer, default: 1
    remove_column :relation_types, :inverse
  end

  def down
    rename_table :relations, :relationships
    remove_column :relation_types, :level
    add_column :relation_types, :inverse, :boolean, default: false
  end
end
