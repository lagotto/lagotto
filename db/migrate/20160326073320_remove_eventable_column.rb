class RemoveEventableColumn < ActiveRecord::Migration
  def up
    remove_column :sources, :eventable
    add_column :contributions, :publisher_id, :integer
  end

  def down
    add_column :sources, :eventable, :boolean, default: true
    remove_column :contributions, :publisher_id
  end
end
