class AddEventColumns < ActiveRecord::Migration
  def up
    add_column :retrieval_statuses, :events_url, :string
    add_column :retrieval_statuses, :event_metrics, :string
    remove_column :retrieval_statuses, :local_id
    remove_column :articles, :mendeley_url
  end

  def down
    remove_column :retrieval_statuses, :events_url
    remove_column :retrieval_statuses, :event_metrics
    add_column :retrieval_statuses, :local_id, :string
    add_column :articles, :mendeley_url, :string
  end
end
