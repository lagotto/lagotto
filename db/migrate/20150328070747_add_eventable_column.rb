class AddEventableColumn < ActiveRecord::Migration
  def up
    add_column :sources, :eventable, :boolean, default: true
  end

  def down
    remove_column :sources, :eventable
  end
end
