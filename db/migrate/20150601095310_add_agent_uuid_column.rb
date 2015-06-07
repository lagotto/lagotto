class AddAgentUuidColumn < ActiveRecord::Migration
  def up
    add_column :agents, :uuid, :string
    remove_column :agents, :eventable
  end

  def down
    remove_column :agents, :uuid
    add_column :agents, :eventable, :boolean
  end
end
