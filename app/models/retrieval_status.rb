class RetrievalStatus < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  # include CouchDB helpers
  include Couchable

  # include methods for calculating metrics
  include Measurable

  belongs_to :work, :touch => true
  belongs_to :source
  has_many :months, :dependent => :destroy
  has_many :days, :dependent => :destroy

  serialize :extra, JSON

  validates :work_id, :source_id, presence: true
  validates_associated :work, :source

  delegate :name, :to => :source
  delegate :title, :to => :source
  delegate :group, :to => :source

  scope :tracked, -> { joins(:work).where("works.tracked = ?", true) }

  scope :with_events, -> { where("total > ?", 0) }
  scope :without_events, -> { where("total = ?", 0) }
  scope :most_cited, -> { with_events.order("total desc").limit(25) }

  scope :last_x_days, ->(duration) { where("retrieved_at >= ?", Time.zone.now.to_date - duration.days) }
  scope :published_last_x_days, ->(duration) { joins(:work).where("works.published_on >= ?", Time.zone.now.to_date - duration.days) }
  scope :published_last_x_months, ->(duration) { joins(:work).where("works.published_on >= ?", Time.zone.now.to_date  - duration.months) }

  scope :queued, -> { tracked.where("queued_at is NOT NULL") }
  scope :not_queued, -> { tracked.where("queued_at is NULL") }
  scope :stale, -> { not_queued.where("scheduled_at < ?", Time.zone.now).order("scheduled_at") }
  scope :published, -> { not_queued.where("works.published_on <= ?", Time.zone.now.to_date) }

  scope :by_source, ->(source_id) { where(:source_id => source_id) }
  scope :by_name, ->(source) { joins(:source).where("sources.name = ?", source) }
  scope :with_sources, -> { joins(:source).where("sources.state > ?", 0).order("group_id, title") }

  def perform_get_data
    data = source.get_data(work, timeout: source.timeout, work_id: work_id, source_id: source_id)

    if ENV["LOGSTASH_PATH"].present?
      # write API response from external source to log/agent.log, using source name and work pid as tags
      AGENT_LOGGER.tagged(source.name, work.pid) { AGENT_LOGGER.info "#{result.inspect}" }
    end

    skipped = data[:error].present?
    previous_total = total
    update_interval = retrieved_days_ago

    # only update database if no error
    unless skipped
      data = source.parse_data(data, work, work_id: work_id, source_id: source_id)

      update_works(data.fetch(:works, []))

      data[:events] = data.fetch(:events, {})
      update_data(data.fetch(:events, {}).except(:days, :months))

      data[:months] = data.fetch(:events, {}).fetch(:months, [])
      data[:months] = [get_events_current_month] if data[:months].blank?
      update_months(data.fetch(:months))

      data[:days] = data.fetch(:events, {}).fetch(:days, [])
      data[:days] = [get_events_current_day].compact if data[:days].blank?
      update_days(data.fetch(:days))
    end

    { total: total,
      html: html,
      pdf: pdf,
      previous_total: previous_total,
      skipped: skipped,
      update_interval: update_interval }
  end

  def update_data(data)
    update_attributes(retrieved_at: Time.zone.now,
                      scheduled_at: stale_at,
                      queued_at: nil,
                      total: data.fetch(:total, 0),
                      pdf: data.fetch(:pdf, 0),
                      html: data.fetch(:html, 0),
                      readers: data.fetch(:readers, 0),
                      comments: data.fetch(:comments, 0),
                      likes: data.fetch(:likes, 0),
                      events_url: data.fetch(:events_url, nil),
                      extra: data.fetch(:extra, nil))
  end

  def update_works(data)
    data.map do |item|
      doi = item.fetch("DOI", nil)
      pmid = item.fetch("PMID", nil)
      pmcid = item.fetch("PMCID", nil)
      arxiv = item.fetch("arxiv", nil)
      canonical_url = item.fetch("URL", nil)
      title = item.fetch("title", nil)
      date_parts = item.fetch("issued", {}).fetch("date-parts", [[]]).first
      year, month, day = date_parts[0], date_parts[1], date_parts[2]
      type = item.fetch("type", nil)
      work_type_id = WorkType.where(name: type).pluck(:id).first
      related_works = item.fetch("related_works", [])

      csl = {
        "author" => item.fetch("author", []),
        "container-title" => item.fetch("container-title", nil),
        "volume" => item.fetch("volume", nil),
        "page" => item.fetch("page", nil),
        "issue" => item.fetch("issue", nil) }

      i = {
        doi: doi,
        pmid: pmid,
        pmcid: pmcid,
        arxiv: arxiv,
        canonical_url: canonical_url,
        title: title,
        year: year,
        month: month,
        day: day,
        work_type_id: work_type_id,
        tracked: false,
        csl: csl,
        related_works: related_works }

      w = Work.find_or_create(i)
      w ? w.pid : nil
    end
  end

  def update_days(data)
    data.map { |item| Day.where(retrieval_status_id: id,
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
    data.map { |item| Month.where(retrieval_status_id: id,
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

  def import_from_couchdb
    # import only for works with dois because we changed the pid format in lagotto 4.0
    return false unless total > 0 && work.doi.present?

    data = get_lagotto_data("#{source.name}:#{work.doi_escaped}")

    by_day = (data.blank? || data[:error]) ? [] : data["events_by_day"]
    update_days({ year: by_day.fetch(:year),
                  month: by_day.fetch(:month),
                  day: by_day.fetch(:day),
                  total: by_day.fetch(:event_count, 0) })

    # only update monthly data for sources where we can't regenerate them
    return true unless ['crossref', 'datacite', 'europe_pmc', 'europe_pmc_data', 'facebook', 'figshare', 'mendeley', 'pubmed', 'scopus', 'wos'].include?(source.name)

    by_month = (data.blank? || data[:error]) ? [] : data["events_by_month"]
    update_months({ year: by_month.fetch(:year),
                    month: by_month.fetch(:month),
                    total: by_month.fetch(:event_count, 0) })
  end

  def retrieved_days_ago
    if [Date.new(1970, 1, 1), today].include?(retrieved_at.to_date)
      1
    else
      (today - retrieved_at.to_date).to_i
    end
  end

  def to_param
    "#{source.name}:#{work.pid}"
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

  def get_events_previous_day
    row = days.last

    if row.nil?
      # first record
      { pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: 0 }
    elsif [row.year, row.month, row.day] == [today.year, today.month, today.day]
      # update today's record
      { pdf: pdf - row.pdf,
        html: html - row.html,
        readers: readers - row.readers,
        comments: comments - row.comments,
        likes: likes - row.likes,
        total: total - row.total }
    else
      # add record
      { pdf: row.pdf,
        html: row.html,
        readers: row.readers,
        comments: row.comments,
        likes: row.likes,
        total: row.total }
    end
  end

  # calculate events for current day based on past numbers
  # track daily events only the first 30 days after publication
  def get_events_current_day
    return nil if today - work.published_on > 30

    row = get_events_previous_day

    { year: today.year,
      month: today.month,
      day: today.day,
      pdf: pdf - row.fetch(:pdf),
      html: html - row.fetch(:html),
      readers: readers - row.fetch(:readers),
      comments: comments - row.fetch(:comments),
      likes: likes - row.fetch(:likes),
      total: total - row.fetch(:total) }
  end

  def get_events_previous_month
    row = months.last

    if row.nil?
      # first record
      { pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: 0 }
    elsif [row.year, row.month] == [today.year, today.month]
      # update this month's record
      { pdf: pdf - row.pdf,
        html: html - row.html,
        readers: readers - row.readers,
        comments: comments - row.comments,
        likes: likes - row.likes,
        total: total - row.total }
    else
      # add record
      { pdf: row.pdf,
        html: row.html,
        readers: row.readers,
        comments: row.comments,
        likes: row.likes,
        total: row.total }
    end
  end

  # calculate events for current month based on past numbers
  def get_events_current_month
    row = get_events_previous_month

    { year: today.year,
      month: today.month,
      pdf: pdf - row.fetch(:pdf),
      html: html - row.fetch(:html),
      readers: readers - row.fetch(:readers),
      comments: comments - row.fetch(:comments),
      likes: likes - row.fetch(:likes),
      total: total - row.fetch(:total) }
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

  # for backwards compatibility in v3 and v5 APIs
  def events
    extra
  end

  def cache_key
    "event/#{id}-#{timestamp}"
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

  def delete_couchdb_document
    remove_lagotto_data(to_param)
  end
end
