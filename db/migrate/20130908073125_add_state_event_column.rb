class AddStateEventColumn < ActiveRecord::Migration
  def up
    add_column :sources, :state_event, :string
  end

  def down
    remove_column :sources, :state_event
  end
end
