class IncreaseColumnSize < ActiveRecord::Migration
  def up
    change_column :delayed_jobs, :handler, :text, :limit => 64.kilobytes + 1
  end

  def down
    change_column :delayed_jobs, :handler, :text
  end
end
