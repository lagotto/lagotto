class RetrievalStatus < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  # include CouchDB helpers
  include Couchable

  # include methods for calculating metrics
  include Measurable

  belongs_to :article, :touch => true
  belongs_to :source
  has_many :retrieval_histories

  before_destroy :delete_couchdb_document

  serialize :event_metrics
  serialize :other, OpenStruct

  delegate :name, :to => :source
  delegate :display_name, :to => :source
  delegate :group, :to => :source

  scope :most_cited, lambda { where("event_count > ?", 0).order("event_count desc").limit(25) }
  scope :most_cited_last_x_days, lambda { |duration| joins(:article).where("event_count > ?", 0).where("articles.published_on >= ?", Date.today - duration.days).order("event_count desc").limit(25) }
  scope :most_cited_last_x_months, lambda { |duration| joins(:article).where("event_count > ?", 0).where("articles.published_on >= ?", Date.today - duration.months).order("event_count desc").limit(25) }

  scope :queued, where("queued_at is NOT NULL")
  scope :not_queued, where("queued_at is NULL")
  scope :stale, where("queued_at is NULL").where("scheduled_at IS NOT NULL").where("scheduled_at <= ?", Time.zone.now).order("scheduled_at")
  scope :published, joins(:article).where("queued_at is NULL").where("articles.published_on <= ?", Date.today)
  scope :with_sources, joins(:source).where("sources.state > ?", 0).order("group_id, display_name")

  scope :total, lambda { |duration| where("retrieved_at > ?", Time.zone.now - duration.days) }
  scope :with_events, lambda { |duration| where("event_count > ?", 0).where("retrieved_at > ?", Time.zone.now - duration.days) }
  scope :without_events, lambda { |duration| where("event_count = ?", 0).where("retrieved_at > ?", Time.zone.now - duration.days) }

  scope :by_source, lambda { |source_ids| where(:source_id => source_ids) }
  scope :by_name, lambda { |source| includes(:source).where("sources.name = ?", source) }

  def perform_get_data
    result = source.get_data(article, timeout: source.timeout, article_id: article_id, source_id: source_id)
    data = source.parse_data(result, article, article_id: article_id, source_id: source_id)
    history = History.new(id, data)
    history.to_hash
  end

  def data
    if event_count > 0
      data = get_lagotto_data("#{source.name}:#{article.uid_escaped}")
    else
      nil
    end
  end

  def events
    if data.blank? || data[:error]
      []
    else
      data["events"]
    end
  end

  def by_day
    if data.blank? || data[:error]
      []
    else
      data["events_by_day"]
    end
  end

  def by_month
    if data.blank? || data[:error]
      []
    else
      data["events_by_month"]
    end
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
    return [] unless events.is_a?(Array)

    events.map { |event| event['event_csl'] }.compact
  end

  def metrics
    if event_metrics.present?
      event_metrics
    else
      get_event_metrics(total: 0)
    end
  end

  def new_metrics
    { :pdf => metrics[:pdf],
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
    group.name
  end

  def update_date
    updated_at.utc.iso8601
  end

  def cache_key
    "#{id}/#{update_date}"
  end

  def delete_document
    unless data_rev.nil
      document_id = "#{source.name}:#{article.uid_escaped}"
      remove_alm_data(document_id, data_rev)
    else
      nil
    end
  end

  # calculate datetime when retrieval_status should be updated, adding random interval
  # sources that are not queueable use a fixed date
  def stale_at
    unless source.queueable
      cron_parser = CronParser.new(source.cron_line)
      return cron_parser.next(Time.zone.now)
    end

    age_in_days = Date.today - article.published_on
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
    couchdb_id = "#{source.name}:#{article.uid_escaped}"
    remove_alm_data(couchdb_id)
  end
end
