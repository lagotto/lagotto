class AddAgentIdColumn < ActiveRecord::Migration
  def change
    add_column :notifications, :agent_id, :integer
  end
end
