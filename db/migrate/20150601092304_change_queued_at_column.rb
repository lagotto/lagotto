class ChangeQueuedAtColumn < ActiveRecord::Migration
  def up
    change_column :tasks, :queued_at, :datetime, :null => true, default: nil
  end

  def down
    change_column :tasks, :queued_at, :datetime, :null => false, default: '1970-01-01 00:00:00'
  end
end
