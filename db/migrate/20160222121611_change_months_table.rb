class ChangeMonthsTable < ActiveRecord::Migration
  def up
    remove_column :months, :event_id
    remove_column :months, :html
    remove_column :months, :pdf
    remove_column :months, :comments
    remove_column :months, :likes
    remove_column :months, :readers

    add_column :months, :relation_id, :integer
    add_column :months, :relation_type_id, :integer

    add_foreign_key "months", "relations", name: "months_relation_id_fk", on_delete: :cascade
    add_foreign_key "months", "relation_types", name: "months_relation_type_id_fk", on_delete: :cascade
  end

  def down
    add_column :months, :event_id, :integer, limit: 4, null: false
    add_column :months, :html, :integer, limit: 4, default: 0, null: false
    add_column :months, :pdf, :integer, limit: 4, default: 0, null: false
    add_column :months, :comments, :integer, limit: 4, default: 0, null: false
    add_column :months, :likes, :integer, limit: 4, default: 0, null: false
    add_column :months, :readers, :integer, limit: 4, default: 0, null: false

    remove_foreign_key "months", "relations"
    remove_foreign_key "months", "relation_types"

    remove_column :months, :relation_id
    remove_column :months, :relation_type_id
  end
end
