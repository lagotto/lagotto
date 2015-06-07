class AllowNullInSourceColumn < ActiveRecord::Migration
  def up
    change_column :agents, :source_id, :integer, :null => true, default: nil
  end

  def down
    change_column :agents, :source_id, :integer, :null => false
  end
end
