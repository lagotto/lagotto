class AddDefaultState < ActiveRecord::Migration
  def up
    change_column :sources, :state, :integer, default: 0
  end

  def down
    change_column :sources, :state, :integer, default: false
  end
end
