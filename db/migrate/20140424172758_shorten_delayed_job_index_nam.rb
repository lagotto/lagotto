class ShortenDelayedJobIndexNam < ActiveRecord::Migration
  def change
    rename_index :delayed_jobs, 'index_delayed_jobs_run_at_locked_at_locked_by_failed_at_priority', 'index_delayed_jobs_run_at_locked_at_failed_at_priority'
  end
end
