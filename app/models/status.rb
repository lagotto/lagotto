class Status
  extend ActiveModel::Naming
  include ActiveModel::Serialization

  attr_reader :id, :state, :jobs, :event_count, :source_count, :work_count

  def initialize
    @id = "status"
    @state = current_status
    @jobs = jobs
    @event_count = event_count
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

  def event_count
    if Rails.env.development? || Rails.env.test?
      Event.count
    else
      Event.cached_event_count
    end
  end

  def source_count
    Source.count
  end

  def work_count
    if Rails.env.development? || Rails.env.test?
      Work.count
    else
      Work.cached_work_count
    end
  end
end
