class AddAgentUuidColumn < ActiveRecord::Migration
  def up
    add_column :agents, :uuid, :string
    remove_column :agents, :eventable
    remove_column :agents, :queueable
  end

  def down
    remove_column :agents, :uuid
    add_column :agents, :eventable, :boolean
    add_column :agents, :queueable, :boolean, default: true
  end
end
