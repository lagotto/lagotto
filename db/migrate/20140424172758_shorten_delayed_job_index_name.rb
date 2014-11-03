class ShortenDelayedJobIndexName < ActiveRecord::Migration
  def change
    rename_index :delayed_jobs, 'index_delayed_jobs_run_at_locked_at_locked_by_failed_at_priority', 'index_delayed_jobs_run_at_locked_at_failed_at_priority'
    rename_index :retrieval_histories, 'index_retrieval_histories_on_source_id_and_status_and_updated_at', 'index_retrieval_histories_on_source_id_and_status_and_updated'
  end
end
