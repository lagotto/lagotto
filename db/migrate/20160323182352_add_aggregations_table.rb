class AddAggregationsTable < ActiveRecord::Migration
  def up
    remove_foreign_key "months", "relations"

    create_table "aggregations", force: :cascade do |t|
      t.integer  "work_id",      limit: 4,                                        null: false
      t.integer  "source_id",    limit: 4,                                        null: false
      t.integer  "relation_type_id", limit: 4,                                    null: false
      t.integer  "total",        limit: 4,        default: 0,                     null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "aggregations", ["source_id", "relation_type_id", "total"], name: "index_on_source_id_relation_type_id_total"
    add_index "aggregations", ["work_id", "relation_type_id", "total"], name: "index_on_work_id_relation_type_id_total"
    add_index "aggregations", ["work_id", "source_id", "relation_type_id", "total"], name: "index_on_work_id_source_id_relation_type_id_total"


    add_column :relations, :aggregation_id, :integer, limit: 4
    add_column :months, :aggregation_id, :integer, limit: 4
    remove_column :months, :relation_id

    add_foreign_key "aggregations", "sources", name: "aggregations_source_id_fk", on_delete: :cascade
    add_foreign_key "aggregations", "works", name: "aggregations_work_id_fk", on_delete: :cascade
    add_foreign_key "months", "aggregations", name: "months_aggregations_id_fk", on_delete: :cascade
    add_foreign_key "relations", "aggregations", name: "relations_aggregations_id_fk", on_delete: :cascade
  end

  def down
    remove_foreign_key "aggregations", "sources"
    remove_foreign_key "aggregations", "works"
    remove_foreign_key "months", "aggregations"
    remove_foreign_key "relations", "aggregations"

    remove_column :relations, :aggregation_id
    remove_column :months, :aggregation_id
    add_column :months, :relation_id, :integer, limit: 4

    drop_table :aggregations

    add_foreign_key "months", "relations", name: "months_relations_id_fk", on_delete: :cascade
  end
end
