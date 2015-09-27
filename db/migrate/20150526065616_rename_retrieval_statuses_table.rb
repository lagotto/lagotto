class RenameRetrievalStatusesTable < ActiveRecord::Migration
  def up
    rename_table :retrieval_statuses, :events
    remove_column :events, :queued_at
    remove_column :events, :scheduled_at

    rename_index :events, 'index_retrieval_statuses_source_id_event_count_retr_at_desc', 'index_events_source_id_total_retrieved_at_desc'
    rename_index :events, 'index_retrieval_statuses_source_id_event_count_desc', 'index_events_source_id_total_desc'
    rename_index :events, 'index_retrieval_statuses_source_id_article_id_event_count_desc', 'index_events_source_id_work_id_total_desc'
    rename_index :events, 'index_rs_on_soure_id_queued_at_scheduled_at', 'index_events_on_soure_id_queued_at_scheduled_at'
    rename_index :events, 'index_rs_on_article_id_soure_id_event_count', 'index_events_on_work_id_source_id_total'
  end

  def down
    rename_table :events, :retrieval_statuses
    add_column :retrieval_statuses, :queued_at, :datetime
    add_column :retrieval_statuses, :scheduled_at, :datetime

    rename_index :events, 'index_events_source_id_total_retrieved_at_desc', 'index_retrieval_statuses_source_id_event_count_retr_at_desc'
    rename_index :events, 'index_events_source_id_total_desc', 'index_retrieval_statuses_source_id_event_count_desc'
    rename_index :events, 'index_events_source_id_work_id_total_desc', 'index_retrieval_statuses_source_id_article_id_event_count_desc'
    rename_index :events, 'index_events_on_soure_id_queued_at_scheduled_at', 'index_rs_on_soure_id_queued_at_scheduled_at'
    rename_index :events, 'index_events_on_work_id_source_id_total', 'index_rs_on_article_id_soure_id_event_count'
  end
end
