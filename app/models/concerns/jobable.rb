module Jobable
  extend ActiveSupport::Concern

  included do
    def get_last_job(queue)
      DelayedJob.where(queue: queue).maximum(:run_at)
    end

    def get_job_count(queue = nil)
      if queue
        DelayedJob.where(queue: queue).count
      else
        DelayedJob.count
      end
    end

    def get_worker_count(queue = nil)
      if queue
        DelayedJob.where(queue: queue).where("locked_by IS NOT NULL").count
      else
        DelayedJob.where("locked_by IS NOT NULL").count
      end
    end

    def delete_jobs(queue)
      DelayedJob.where(queue: queue).delete_all
    end

  end
end
