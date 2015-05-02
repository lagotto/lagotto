class IncreasePidColumnSize < ActiveRecord::Migration
  def up
    change_column :works, :pid, :text, null: false
  end

  def down
    change_column :works, :pid, :string, null: false
  end
end
