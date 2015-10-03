class AddUniqueIndexRelations < ActiveRecord::Migration
  def change
    add_index :relations, [:work_id, :related_work_id, :source_id], unique: true
  end
end
