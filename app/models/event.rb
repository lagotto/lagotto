class Event < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  # include methods for calculating metrics
  include Measurable

  belongs_to :work, :touch => true
  belongs_to :source
  has_many :months, :dependent => :destroy

  serialize :extra, JSON

  validates :work_id, :source_id, presence: true
  validates_associated :work, :source

  delegate :name, :to => :source
  delegate :title, :to => :source
  delegate :group, :to => :source

  scope :tracked, -> { joins(:work).where("works.tracked = ?", true) }

  scope :last_x_days, ->(duration) { tracked.where("retrieved_at >= ?", Time.zone.now.to_date - duration.days) }
  scope :not_updated, ->(duration) { tracked.where("retrieved_at < ?", Time.zone.now.to_date - duration.days) }

  scope :published_last_x_days, ->(duration) { joins(:work).where("works.published_on >= ?", Time.zone.now.to_date - duration.days) }
  scope :published_last_x_months, ->(duration) { joins(:work).where("works.published_on >= ?", Time.zone.now.to_date  - duration.months) }

  scope :with_events, -> { where("total > ?", 0) }
  scope :without_events, -> { where("total = ?", 0) }
  scope :most_cited, -> { with_events.order("total desc").limit(25) }
  scope :with_sources, -> { joins(:source).where("sources.active = ?", 1).order("group_id, title") }

  def to_param
    "#{source.name}:#{work.pid}"
  end

  def get_events_previous_day
    row = days.last

    if row.nil?
      # first record
      { "pdf" => 0, "html" => 0, "readers" => 0, "comments" => 0, "likes" => 0, "total" => 0 }
    elsif [row.year, row.month, row.day] == [today.year, today.month, today.day]
      # update today's record
      { "pdf" => pdf - row.pdf,
        "html" => html - row.html,
        "readers" => readers - row.readers,
        "comments" => comments - row.comments,
        "likes" => likes - row.likes,
        "total" => total - row.total }
    else
      # add record
      { "pdf" => row.pdf,
        "html" => row.html,
        "readers" => row.readers,
        "comments" => row.comments,
        "likes" => row.likes,
        "total" => row.total }
    end
  end

  # calculate events for current day based on past numbers
  # track daily events only the first 30 days after publication
  def get_events_current_day
    return nil if today - work.published_on > 30

    row = get_events_previous_day

    { "year" => today.year,
      "month" => today.month,
      "day" => today.day,
      "pdf" => pdf - row.fetch("pdf"),
      "html" => html - row.fetch("html"),
      "readers" => readers - row.fetch("readers"),
      "comments" => comments - row.fetch("comments"),
      "likes" => likes - row.fetch("likes"),
      "total" => total - row.fetch("total") }
  end

  def get_events_previous_month
    row = months.last

    if row.nil?
      # first record
      { "pdf" => 0, "html" => 0, "readers" => 0, "comments" => 0, "likes" => 0, "total" => 0 }
    elsif [row.year, row.month] == [today.year, today.month]
      # update this month's record
      { "pdf" => pdf - row.pdf,
        "html" => html - row.html,
        "readers" => readers - row.readers,
        "comments" => comments - row.comments,
        "likes" => likes - row.likes,
        "total" => total - row.total }
    else
      # add record
      { "pdf" => row.pdf,
        "html" => row.html,
        "readers" => row.readers,
        "comments" => row.comments,
        "likes" => row.likes,
        "total" => row.total }
    end
  end

  # calculate events for current month based on past numbers
  def get_events_current_month
    row = get_events_previous_month

    { "year" => today.year,
      "month" => today.month,
      "pdf" => pdf - row.fetch("pdf"),
      "html" => html - row.fetch("html"),
      "readers" => readers - row.fetch("readers"),
      "comments" => comments - row.fetch("comments"),
      "likes" => likes - row.fetch("likes"),
      "total" => total - row.fetch("total") }
  end

  # dates via utc time are more accurate than Date.today
  def today
    Time.zone.now.to_date
  end

  def by_day
    days.map { |day| day.metrics }
  end

  def by_month
    months.map { |month| month.metrics }
  end

  def by_year
    return [] if by_month.blank?

    by_month.group_by { |event| event[:year] }.sort.map do |k, v|
      { year: k.to_i,
        pdf: v.reduce(0) { |sum, hsh| sum + hsh.fetch(:pdf) },
        html: v.reduce(0) { |sum, hsh| sum + hsh.fetch(:html) },
        readers: v.reduce(0) { |sum, hsh| sum + hsh.fetch(:readers) },
        comments: v.reduce(0) { |sum, hsh| sum + hsh.fetch(:comments) },
        likes: v.reduce(0) { |sum, hsh| sum + hsh.fetch(:likes) },
        total: v.reduce(0) { |sum, hsh| sum + hsh.fetch(:total) } }
    end
  end

  def metrics
    @metrics ||= { pdf: pdf,
                   html: html,
                   readers: readers,
                   comments: comments,
                   likes: likes,
                   total: total }
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

  def group_name
    @group_name ||= group.name
  end

  def title
    @title ||= source.title
  end

  def timestamp
    updated_at.utc.iso8601
  end

  alias_method :display_name, :title
  alias_method :update_date, :timestamp

  def update_days(data)
    Array(data).map { |item| Day.where(event_id: id,
                                day: item[:day],
                                month: item[:month],
                                year: item[:year]).first_or_create(
                                  work_id: work_id,
                                  source_id: source_id,
                                  total: item.fetch(:total, 0),
                                  pdf: item.fetch(:pdf, 0),
                                  html: item.fetch(:html, 0),
                                  readers: item.fetch(:readers, 0),
                                  comments: item.fetch(:comments, 0),
                                  likes: item.fetch(:likes, 0)) }
  end

  def update_months(data)
    Array(data).map { |item| Month.where(event_id: id,
                                  month: item[:month],
                                  year: item[:year]).first_or_create(
                                    work_id: work_id,
                                    source_id: source_id,
                                    total: item.fetch(:total, 0),
                                    pdf: item.fetch(:pdf, 0),
                                    html: item.fetch(:html, 0),
                                    readers: item.fetch(:readers, 0),
                                    comments: item.fetch(:comments, 0),
                                    likes: item.fetch(:likes, 0)) }
  end

  # for backwards compatibility in v3 and v5 APIs
  def events
    extra
  end

  def cache_key
    "event/#{id}-#{timestamp}"
  end
end
