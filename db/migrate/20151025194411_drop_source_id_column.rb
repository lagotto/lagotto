class DropSourceIdColumn < ActiveRecord::Migration
  def change
    remove_column :agents, :source_id, :integer
    remove_column :works, :pid_type, :string, default: "url"
  end
end
