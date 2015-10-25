class DropSourceIdColumn < ActiveRecord::Migration
  def change
    remove_column :agents, :source_id, :integer
  end
end
