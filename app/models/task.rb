class Task < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  # include CouchDB helpers
  include Couchable

  # include methods for calculating metrics
  include Measurable

  belongs_to :work, :touch => true
  belongs_to :agent
  has_many :api_responses

  delegate :name, :to => :agent
  delegate :title, :to => :agent
  delegate :group, :to => :agent

  scope :tracked, -> { joins(:work).where("works.tracked = ?", true) }

  scope :last_x_days, ->(duration) { tracked.where("retrieved_at >= ?", Time.zone.now.to_date - duration.days) }
  scope :not_updated, ->(duration) { tracked.where("retrieved_at < ?", Time.zone.now.to_date - duration.days) }

  scope :queued, -> { tracked.where("queued_at is NOT NULL") }
  scope :not_queued, -> { tracked.where("queued_at is NULL") }
  scope :stale, -> { not_queued.where("scheduled_at <= ?", Time.zone.now).order("scheduled_at") }
  scope :refreshed, -> { not_queued.where("scheduled_at > ?", Time.zone.now) }
  scope :published, -> { not_queued.where("works.published_on <= ?", Time.zone.now.to_date) }

  scope :by_agent, ->(agent_id) { where(:agent_id => agent_id) }
  scope :by_name, ->(agent) { joins(:agent).where("agents.name = ?", agent) }

  def perform_get_data
    data = agent.get_data(work, timeout: agent.timeout, work_id: work_id, agent_id: agent_id)

    if ENV["LOGSTASH_PATH"].present?
      # write API response from external agent to log/agent.log, using agent name and work pid as tags
      AGENT_LOGGER.tagged(agent.name, work.pid) { AGENT_LOGGER.info "#{result.inspect}" }
    end

    data = agent.parse_data(data, work, work_id: work_id, agent_id: agent_id)

    # push to deposit API if no error and we have collected events
    return {} if data[:error].present? || data.fetch(:events, [{}]).first.fetch(:total, 0) == 0

    deposit = Deposit.create(uuid: SecureRandom.uuid,
                             source_token: agent.name,
                             message_type: agent.source_id,
                             message: data)

    { uuid: deposit.uuid,
      source_token: deposit.source_token,
      message_type: deposit.message_type }
  end

  def group_name
    @group_name ||= group.name
  end

  # dates via utc time are more accurate than Date.today
  def today
    Time.zone.now.to_date
  end

  def retrieved_days_ago
    if [Date.new(1970, 1, 1), today].include?(retrieved_at.to_date)
      1
    else
      (today - retrieved_at.to_date).to_i
    end
  end

  def update_date
    updated_at.utc.iso8601
  end

  def cache_key
    "#{id}/#{update_date}"
  end

  # calculate datetime when event should be updated, adding random interval
  # agents that are not queueable use a fixed date
  def stale_at
    unless agent.queueable
      cron_parser = CronParser.new(agent.cron_line)
      return cron_parser.next(Time.zone.now)
    end

    age_in_days = Time.zone.now.to_date - work.published_on
    if (0..7).include?(age_in_days)
      random_time(agent.staleness[0])
    elsif (8..31).include?(age_in_days)
      random_time(agent.staleness[1])
    elsif (32..365).include?(age_in_days)
      random_time(agent.staleness[2])
    else
      random_time(agent.staleness.last)
    end
  end

  def random_time(duration)
    Time.zone.now + duration + rand(duration/10)
  end

  def delete_couchdb_document
    remove_lagotto_data(to_param)
  end
end
