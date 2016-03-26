class RemoveEventableColumn < ActiveRecord::Migration
  def up
    remove_column :sources, :eventable
  end

  def down
    add_column :sources, :eventable, :boolean, default: true
  end
end
