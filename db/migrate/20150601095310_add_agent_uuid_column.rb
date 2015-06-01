class AddAgentUuidColumn < ActiveRecord::Migration
  def up
    add_column :agents, :uuid, :string
  end

  def down
    remove_column :agents, :uuid
  end
end
