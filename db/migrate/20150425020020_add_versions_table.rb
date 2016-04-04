class AddVersionsTable < ActiveRecord::Migration
  def up
    rename_table :relationships, :relations
    remove_column :relation_types, :inverse
  end

  def down
    rename_table :relations, :relationships
    add_column :relation_types, :inverse, :boolean, default: false
  end
end
