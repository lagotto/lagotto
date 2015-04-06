class RetrievalStatus < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  # include CouchDB helpers
  include Couchable

  # include methods for calculating metrics
  include Measurable

  belongs_to :work, :touch => true
  belongs_to :source
  has_many :months
  has_many :days
  has_many :retrieval_histories

  before_destroy :delete_couchdb_document

  serialize :event_metrics
  serialize :extra, OpenStruct

  delegate :name, :to => :source
  delegate :title, :to => :source
  delegate :group, :to => :source

  scope :with_events, -> { where("total > ?", 0) }
  scope :without_events, -> { where("total = ?", 0) }
  scope :most_cited, -> { with_events.order("total desc").limit(25) }

  scope :last_x_days, ->(duration) { where("retrieved_at >= ?", Time.zone.now.to_date - duration.days) }
  scope :published_last_x_days, ->(duration) { joins(:work).where("works.published_on >= ?", Time.zone.now.to_date - duration.days) }
  scope :published_last_x_months, ->(duration) { joins(:work).where("works.published_on >= ?", Time.zone.now.to_date  - duration.months) }

  scope :queued, -> { where("queued_at is NOT NULL") }
  scope :not_queued, -> { where("queued_at is NULL") }
  scope :stale, -> { not_queued.where("scheduled_at < ?", Time.zone.now).order("scheduled_at") }
  scope :published, -> { joins(:work).not_queued.where("works.published_on <= ?", Time.zone.now.to_date) }
  scope :tracked, -> { joins(:work).where("tracked = ?", true) }

  scope :by_source, ->(source_id) { where(:source_id => source_id) }
  scope :by_name, ->(source) { joins(:source).where("sources.name = ?", source) }
  scope :with_sources, -> { joins(:source).where("sources.state > ?", 0).order("group_id, title") }

  def perform_get_data
    result = source.get_data(work, timeout: source.timeout, work_id: work_id, source_id: source_id)

    if ENV["LOGSTASH_PATH"].present?
      # write API response from external source to log/agent.log, using source name and work pid as tags
      AGENT_LOGGER.tagged(source.name, work.pid) { AGENT_LOGGER.info "#{result.inspect}" }
    end

    data = source.parse_data(result, work, work_id: work_id, source_id: source_id)
    history = History.new(id, data)
    history.to_hash
  end

  def to_param
    "#{source.name}:#{work.pid}"
  end

  def events
    []
  end

  def by_day
    days.map { |day| day.metrics }
  end

  def by_month
    months.map { |month| month.metrics }
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

  def metrics
    @metrics ||= { pdf: pdf,
                   html: html,
                   readers: readers,
                   comments: comments,
                   likes: likes,
                   total: total }.reject { |k,v| v.to_i == 0 }
  end

  # for backwards compatibility with v3 API
  def old_metrics
    @old_metrics ||= { pdf: pdf,
                       html: html,
                       shares: readers,
                       groups: readers > 0 ? total - readers : 0,
                       comments: comments,
                       likes: likes,
                       citations: pdf + html + readers + comments + likes > 0 ? 0 : total,
                       total: total }
  end

  def get_past_events_by_month
    retrieval_histories.group_by { |item| item.retrieved_at.strftime("%Y-%m") }.sort.map { |k, v| { :year => k[0..3].to_i, :month => k[5..6].to_i, :total => v.last.event_count } }
  end

  def group_name
    @group_name ||= group.name
  end

  def display_name
    @display_name ||= source.title
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
    remove_lagotto_data(to_param)
  end
end
