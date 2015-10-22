class RemoveAgentKindColumn < ActiveRecord::Migration
  def change
    remove_column :agents, :kind
  end
end
