class AddStateEventColumn < ActiveRecord::Migration
  def up
    add_column :sources, :state_event, :string
    remove_column :sources, :queue
  end

  def down
    remove_column :sources, :state_event
    add_column :sources, :queue, :string
  end
end
