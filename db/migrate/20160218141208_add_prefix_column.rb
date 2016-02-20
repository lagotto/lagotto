class AddPrefixColumn < ActiveRecord::Migration
  def up
    add_column :deposits, :prefix, :string, limit: 191
    add_column :deposits, :subject_id, :string, limit: 191
    add_column :deposits, :object_id, :string, limit: 191
    add_column :deposits, :relation_type_id, :string, limit: 191
    add_column :deposits, :source_id, :string, limit: 191
    add_column :deposits, :publisher_id, :string, limit: 191
    add_column :deposits, :subject, :text
    add_column :deposits, :object, :text
    add_column :deposits, :occured_at, :datetime
    change_column :deposits, :message_type, :string, limit: 191, default: "work"
    remove_column :deposits, :message

    add_index "deposits", ["prefix", "created_at"], name: "index_deposits_on_prefix_created_at"
    add_index "deposits", ["source_id", "created_at"], name: "index_deposits_on_source_id_created_at"
    remove_column :relation_types, :level
  end

  def down
    remove_index "deposits", name: "index_deposits_on_prefix_created_at"
    remove_index "deposits", name: "index_deposits_on_source_id_created_at"

    remove_column :deposits, :prefix
    remove_column :deposits, :subject_id
    remove_column :deposits, :object_id
    remove_column :deposits, :relation_type_id
    remove_column :deposits, :source_id
    remove_column :deposits, :publisher_id
    remove_column :deposits, :subject
    remove_column :deposits, :object
    remove_column :deposits, :occured_at
    change_column :deposits, :message_type, :string, limit: 255, default: "default"
    add_column :deposits, :message, :text, limit: 2048.kilobytes + 1

    add_column :relation_types, :level, :integer, limit: 4, default: 1
  end
end
