class AddForeignKeyRelations < ActiveRecord::Migration
  def change
    add_foreign_key :relations, :works, name: "relations_work_id_fk", on_delete: :cascade
    add_foreign_key :relations, :works, column: :related_work_id, primary_key: :id, name: "relations_related_work_id_fk", on_delete: :cascade
    add_foreign_key :relations, :sources, name: "relations_source_id_fk", on_delete: :cascade
    add_foreign_key :relations, :relation_types, name: "relations_relation_type_id_fk"
  end
end
