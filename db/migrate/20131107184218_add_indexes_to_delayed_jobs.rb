class AddIndexesToDelayedJobs < ActiveRecord::Migration
  def change
    #CREATE INDEX index_delayed_jobs_locked_at_locked_by_failed_at ON `delayed_jobs` (`locked_at` ASC, locked_by ASC, failed_at ASC);
    add_index :delayed_jobs, [:locked_at, :locked_by, :failed_at], :name => 'index_delayed_jobs_locked_at_locked_by_failed_at'


    #add index for this too: SELECT COUNT(`delayed_jobs`.`id`) FROM `delayed_jobs`  WHERE (queue = 'crossref');
    add_index :delayed_jobs, [:queue], :name => 'index_delayed_jobs_queue'

    #UPDATE `delayed_jobs` SET `locked_at` = '2013-11-07 18:48:21', `locked_by` = 'host:serrano pid:1068' WHERE ((run_at <= '2013-11-07 18:48:21' AND (locked_at IS NULL OR locked_at < '2013-11-07 14:48:21') OR locked_by = 'host:serrano pid:1068') AND failed_at IS NULL) ORDER BY priority ASC, run_at ASC LIMIT 1;
    add_index :delayed_jobs, [:run_at, :locked_at, :locked_by, :failed_at, :priority], :name => 'index_delayed_jobs_run_at_locked_at_locked_by_failed_at_priority'
  end
end
