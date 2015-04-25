class AddVersionsTable < ActiveRecord::Migration
  def up
    rename_table :relationships, :reference_relations
    add_column :relation_types, :describes_reference, :boolean, default: true

    create_table "version_relations", force: :cascade do |t|
      t.integer  "work_id",          limit: 4,             null: false
      t.integer  "related_work_id",  limit: 4,             null: false
      t.integer  "source_id",        limit: 4
      t.integer  "relation_type_id", limit: 4,             null: false
      t.datetime "created_at",                             null: false
      t.datetime "updated_at",                             null: false
      t.integer  "level",            limit: 4, default: 1
    end
  end

  def down
    rename_table :reference_relations, :relationships
    remove_column :relation_types, :describes_reference
    drop_table :version_relations
  end
end
