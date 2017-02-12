class Status
  extend ActiveModel::Naming
  include ActiveModel::Serialization

  attr_reader :id, :state, :jobs, :deposit_count, :source_count, :work_count

  def initialize
    @id = "status"
    @state = current_status
    @jobs = jobs
    @deposit_count = deposit_count
    @source_count = source_count
    @work_count = work_count
  end

  def jobs
    { processed: stats.processed,
      failed: stats.failed,
      busy: workers_size,
      enqueued: stats.enqueued,
      retries: stats.retry_size,
      scheduled: stats.scheduled_size,
      dead: stats.dead_size }
  end

  def workers_size
    @workers_size ||= workers.size
  end

  def workers
    @workers ||= Sidekiq::Workers.new
  end

  def stats
    @stats ||= Sidekiq::Stats.new
  end

  def current_status
    if workers_size > 0
      "working"
    elsif process_set.size > 0
      "waiting"
    else
      "stopped"
    end
  end

  def process_set
    @process_set ||= Sidekiq::ProcessSet.new
  end

  def deposit_count
    if Rails.env.development? || Rails.env.test?
      Deposit.count
    else
      Deposit.cached_deposit_count
    end
  end

  def source_count
    Source.active.count
  end

  def work_count
    if Rails.env.development? || Rails.env.test?
      Work.tracked.count
    else
      Work.cached_work_count
    end
  end
end
