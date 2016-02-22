class AddPrefixColumn < ActiveRecord::Migration
  def up
    add_column :deposits, :prefix, :string, limit: 191
    add_column :deposits, :subj_id, :string, limit: 191
    add_column :deposits, :obj_id, :string, limit: 191
    add_column :deposits, :relation_type_id, :string, limit: 191
    add_column :deposits, :source_id, :string, limit: 191
    add_column :deposits, :publisher_id, :string, limit: 191
    add_column :deposits, :subj, :text
    add_column :deposits, :obj, :text
    add_column :deposits, :total, :integer, default: 1
    add_column :deposits, :occurred_at, :datetime
    add_column :deposits, :error_messages, :text
    change_column :deposits, :message_type, :string, limit: 191, default: "relation"
    remove_column :deposits, :message

    add_index "deposits", ["prefix", "created_at"], name: "index_deposits_on_prefix_created_at"
    add_index "deposits", ["source_id", "created_at"], name: "index_deposits_on_source_id_created_at"

    remove_column :relation_types, :level
    remove_column :relations, :level

    remove_index "relations", name: "index_relations_on_level_work_related_work"
  end

  def down
    remove_index "deposits", name: "index_deposits_on_prefix_created_at"
    remove_index "deposits", name: "index_deposits_on_source_id_created_at"

    remove_column :deposits, :prefix
    remove_column :deposits, :subj_id
    remove_column :deposits, :obj_id
    remove_column :deposits, :relation_type_id
    remove_column :deposits, :source_id
    remove_column :deposits, :publisher_id
    remove_column :deposits, :subj
    remove_column :deposits, :obj
    remove_column :deposits, :total
    remove_column :deposits, :occurred_at
    remove_column :deposits, :error_messages
    change_column :deposits, :message_type, :string, limit: 255, default: "default"
    add_column :deposits, :message, :text, limit: 2048.kilobytes + 1

    add_column :relation_types, :level, :integer, limit: 4, default: 1
    add_column :relations, :level, :integer, limit: 4, default: 1

    add_index "relations", ["level", "work_id", "related_work_id"], name: "index_relations_on_level_work_related_work"
  end
end
