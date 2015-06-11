class ChangeTrackedDefault < ActiveRecord::Migration
  def up
    change_column :works, :tracked, :boolean, default: false
  end

  def down
    change_column :works, :tracked, :boolean, default: true
  end
end
