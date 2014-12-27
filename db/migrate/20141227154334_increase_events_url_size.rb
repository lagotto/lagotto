class IncreaseEventsUrlSize < ActiveRecord::Migration
  def up
    change_column :retrieval_statuses, :events_url, :text
  end

  def down
    change_column :retrieval_statuses, :events_url, :string
  end
end
