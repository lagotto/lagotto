module Delayed
  module Heartbeat

    def self.unlock_orphaned_jobs(timeout_minutes = Rails.configuration.jobs.heartbeat_timeout_minutes)
      WorkerModel.dead_workers(timeout_minutes).delete_all
      orphaned_jobs = Delayed::Job.where("locked_at IS NOT NULL AND " \
              "locked_by NOT IN (#{WorkerModel.active_names.to_sql})")
      orphaned_jobs.update_all('locked_at = NULL, locked_by = NULL, attempts = attempts + 1')
    end
  end
end