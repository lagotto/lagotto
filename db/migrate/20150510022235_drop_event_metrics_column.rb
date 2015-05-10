class DropEventMetricsColumn < ActiveRecord::Migration
  def up
    remove_column :retrieval_statuses, :event_metrics
  end

  def down
    add_column :retrieval_statuses, :event_metrics, :text
  end
end
