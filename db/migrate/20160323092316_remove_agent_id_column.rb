class RemoveAgentIdColumn < ActiveRecord::Migration
  def up
    remove_column :notifications, :agent_id
  end

  def down
    add_column :notifications, :agent_id, :integer, limit: 4
  end
end
