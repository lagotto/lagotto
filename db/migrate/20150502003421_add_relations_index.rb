class AddRelationsIndex < ActiveRecord::Migration
  def up
    add_index "relations", ["level", "work_id", "related_work_id"], name: "index_relations_on_level_work_related_work"
  end

  def down
    add_index "relations", name: "index_relations_on_level_work_related_work"
  end
end
