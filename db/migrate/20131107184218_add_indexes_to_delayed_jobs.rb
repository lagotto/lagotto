class AddIndexesToDelayedJobs < ActiveRecord::Migration
  def change
    # CREATE INDEX index_delayed_jobs_locked_at_locked_by_failed_at ON `delayed_jobs` (`locked_at` ASC, locked_by ASC, failed_at ASC);
    add_index :delayed_jobs, [:locked_at, :locked_by, :failed_at], :name => 'index_delayed_jobs_locked_at_locked_by_failed_at'

    # add index for this too: SELECT COUNT(`delayed_jobs`.`id`) FROM `delayed_jobs`  WHERE (queue = 'crossref');
    add_index :delayed_jobs, [:queue], :name => 'index_delayed_jobs_queue'

    add_index :delayed_jobs, [:run_at, :locked_at, :locked_by, :failed_at, :priority], :name => 'index_delayed_jobs_run_at_locked_at_failed_at_priority'
  end
end
