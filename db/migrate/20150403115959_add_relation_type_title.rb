class AddRelationTypeTitle < ActiveRecord::Migration
  def up
    add_column :relation_types, :title, :string
    add_column :relation_types, :inverse_title, :string

    rename_table :events, :relations
    rename_column :relations, :citation_id, :related_work_id
  end

  def down
    remove_column :relation_types, :title
    remove_column :relation_types, :inverse_title

    rename_column :relations, :related_work_id, :citation_id
    rename_table :relations, :events
  end
end
