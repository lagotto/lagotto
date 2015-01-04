class RetrievalStatus < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  # include CouchDB helpers
  include Couchable

  # include methods for calculating metrics
  include Measurable

  belongs_to :work, :touch => true
  belongs_to :source
  has_many :retrieval_histories

  before_destroy :delete_couchdb_document

  serialize :event_metrics
  serialize :other, OpenStruct

  delegate :name, :to => :source
  delegate :display_name, :to => :source
  delegate :group, :to => :source

  scope :with_events, -> { where("event_count > ?", 0) }
  scope :without_events, -> { where("event_count = ?", 0) }
  scope :most_cited, -> { with_events.order("event_count desc").limit(25) }

  scope :last_x_days, ->(duration) { where("retrieved_at >= ?", Time.zone.now.to_date - duration.days) }
  scope :published_last_x_days, ->(duration) { joins(:work).where("works.published_on >= ?", Time.zone.now.to_date - duration.days) }
  scope :published_last_x_months, ->(duration) { joins(:work).where("works.published_on >= ?", Time.zone.now.to_date  - duration.months) }

  scope :queued, -> { where("queued_at is NOT NULL") }
  scope :not_queued, -> { where("queued_at is NULL") }
  scope :stale, -> { not_queued.where("scheduled_at < ?", Time.zone.now).order("scheduled_at") }
  scope :published, -> { joins(:work).not_queued.where("works.published_on <= ?", Time.zone.now.to_date) }

  scope :by_source, ->(source_id) { where(:source_id => source_id) }
  scope :by_name, ->(source) { joins(:source).where("sources.name = ?", source) }
  scope :with_sources, -> { joins(:source).where("sources.state > ?", 0).order("group_id, display_name") }

  def perform_get_data
    result = source.get_data(work, timeout: source.timeout, work_id: work_id, source_id: source_id)

    # write API response from external source to log/agent.log, using source name and work pid as tags
    AGENT_LOGGER.tagged(source.name, work.pid) { AGENT_LOGGER.info "#{result.inspect}" }

    data = source.parse_data(result, work, work_id: work_id, source_id: source_id)
    history = History.new(id, data)
    history.to_hash
  end

  def data
    @data ||= event_count > 0 ? get_lagotto_data("#{source.name}:#{work.pid_escaped}") : nil
  end

  def events
    @events ||= (data.blank? || data[:error]) ? [] : data["events"]
  end

  def by_day
    @by_day ||= (data.blank? || data[:error]) ? [] : data["events_by_day"]
  end

  def by_month
    @by_month ||= (data.blank? || data[:error]) ? [] : data["events_by_month"]
  end

  def by_year
    return [] if by_month.blank?

    by_month.group_by { |event| event["year"] }.sort.map do |k, v|
      if ['counter', 'pmc', 'figshare', 'copernicus'].include?(name)
        { year: k.to_i,
          pdf: v.reduce(0) { |sum, hash| sum + hash['pdf'].to_i },
          html: v.reduce(0) { |sum, hash| sum + hash['html'].to_i } }
      else
        { year: k.to_i,
          total: v.reduce(0) { |sum, hash| sum + hash['total'].to_i } }
      end
    end
  end

  def events_csl
    @events_csl ||= events.is_a?(Array) ? events.map { |event| event['event_csl'] }.compact : []
  end

  def metrics
    @metrics ||= event_metrics.present? ? event_metrics : get_event_metrics(total: 0)
  end

  def new_metrics
    @new_metrics ||= { :pdf => metrics[:pdf],
                       :html => metrics[:html],
                       :readers => metrics[:shares],
                       :comments => metrics[:comments],
                       :likes => metrics[:likes],
                       :total => metrics[:total] }
  end

  def get_past_events_by_month
    retrieval_histories.group_by { |item| item.retrieved_at.strftime("%Y-%m") }.sort.map { |k, v| { :year => k[0..3].to_i, :month => k[5..6].to_i, :total => v.last.event_count } }
  end

  def group_name
    @group_name ||= group.name
  end

  def update_date
    updated_at.utc.iso8601
  end

  def cache_key
    "#{id}/#{update_date}"
  end

  # calculate datetime when retrieval_status should be updated, adding random interval
  # sources that are not queueable use a fixed date
  def stale_at
    unless source.queueable
      cron_parser = CronParser.new(source.cron_line)
      return cron_parser.next(Time.zone.now)
    end

    age_in_days = Time.zone.now.to_date - work.published_on
    if (0..7).include?(age_in_days)
      random_time(source.staleness[0])
    elsif (8..31).include?(age_in_days)
      random_time(source.staleness[1])
    elsif (32..365).include?(age_in_days)
      random_time(source.staleness[2])
    else
      random_time(source.staleness.last)
    end
  end

  def random_time(duration)
    Time.zone.now + duration + rand(duration/10)
  end

  private

  def delete_couchdb_document
    couchdb_id = "#{source.name}:#{work.pid}"
    remove_lagotto_data(couchdb_id)
  end
end
