require "cgi"

class History
  # we can get data_from_source in 3 different formats
  # - hash with total == 0:         SUCCESS NO DATA
  # - hash with total >  0:         SUCCESS
  # - hash with total nil or error: ERROR
  #
  # SUCCESS NO DATA
  # The source knows about the work identifier, but returns an total of 0
  #
  # SUCCESS
  # The source knows about the work identifier, and returns an total > 0
  #
  # ERROR
  # An error occured, typically 408 (Request Timeout), 403 (Too Many Requests) or 401 (Unauthorized)
  # It could also be an error in our code. 404 (Not Found) errors are handled as SUCCESS NO DATA
  # We don't update retrieval status and set skipped to true,
  # so that the request is repeated later. We could get stuck, but we see this in alerts
  #
  # This class returns a hash in the format total: 12, previous_total: 8, skipped: false, update_interval: 31
  # This hash can be used to track API responses, e.g. when event counts go down

  # include HTTP request helpers
  include Networkable

  # include metrics helpers
  include Measurable

  attr_accessor :retrieval_status, :works, :total, :pdf, :html, :readers, :comments, :likes, :extra, :previous_total, :previous_retrieved_at, :event_metrics, :events_by_day, :events_by_month, :events_url, :status, :rs_rev, :rh_rev, :data

  def initialize(rs_id, data = {})
    @retrieval_status = RetrievalStatus.find(rs_id)
    @previous_total = retrieval_status.total
    @previous_retrieved_at = retrieval_status.retrieved_at

    @status = case
              when data[:error] || data[:total].nil? then :error
              when data[:total] > 0 then :success
              when data[:total] == 0 then :success_no_data
              end

    @pdf = data.fetch(:pdf, 0)
    @html = data.fetch(:html, 0)
    @readers = data.fetch(:readers, 0)
    @comments = data.fetch(:comments, 0)
    @likes = data.fetch(:likes, 0)
    @total = data.fetch(:total, 0)

    @extra = data.fetch(:extra, nil)

    if not_error?
      @event_metrics = data[:event_metrics] || get_event_metrics(citations: 0)
      @events_url = data[:events_url]

      save_to_retrieval_statuses
    end

    if success?
      @events_by_day = data[:events_by_day]
      @events_by_day = [get_events_current_day].compact if events_by_day.blank?

      @events_by_month = data[:events_by_month]
      @events_by_month = [get_events_current_month] if events_by_month.blank?

      save_to_works
      save_to_days
      save_to_months
    end
  end

  def save_to_retrieval_statuses
    # save data to retrieval_status table
    retrieval_status.update_attributes(retrieved_at: retrieved_at,
                                       scheduled_at: retrieval_status.stale_at,
                                       queued_at: nil,
                                       total: total,
                                       pdf: pdf,
                                       html: html,
                                       readers: readers,
                                       comments: comments,
                                       likes: likes,
                                       event_metrics: event_metrics,
                                       events_url: events_url,
                                       extra: extra)
  end

  def works
    return [] if data.nil?

    Array(data.fetch(:events, nil)).map do |item|
      doi = item.fetch("DOI", nil)
      canonical_url = item.fetch("URL", nil)
      date_parts = item.fetch("issued", {}).fetch("date-parts", []).first
      year, month, day = date_parts[0], date_parts[1], date_parts[2]
      type = item.fetch("type", nil)
      work_type_id = WorkType.where(name: type).pluck(:id).first

      csl = {
        "issued" => item.fetch("issued", []),
        "author" => item.fetch("author", []),
        "container-title" => item.fetch("container-title", nil),
        "page" => item.fetch("page", nil),
        "issue" => item.fetch("issue", nil),
        "title" => item.fetch("title", nil),
        "type" => item.fetch("type", nil),
        "DOI" => doi,
        "URL" => canonical_url,
        "volume" => item.fetch("volume", nil) }

      { doi: doi,
        title: title,
        year: year,
        month: month,
        day: day,
        publisher_id: publisher_id,
        work_type_id: work_type_id,
        tracked: false,
        csl: csl }
    end
  end

  def save_to_works
    works.map { |item| Work.find_or_create(item) }
  end

  def save_to_days
    Array(events_by_day).map { |item| Day.where(retrieval_status_id: retrieval_status.id,
                                                day: item[:day],
                                                month: item[:month],
                                                year: item[:year]).first_or_create(
                                                work_id: retrieval_status.work_id,
                                                source_id: retrieval_status.source_id,
                                                total: item.fetch(:total, 0),
                                                pdf: item.fetch(:pdf, nil),
                                                html: item.fetch(:html, nil),
                                                readers: item.fetch(:readers, nil),
                                                comments: item.fetch(:comments, nil),
                                                likes: item.fetch(:likes, nil)) }
  end

  def save_to_months
    Array(events_by_month).map { |item| Month.where(retrieval_status_id: retrieval_status.id,
                                                    month: item[:month],
                                                    year: item[:year]).first_or_create(
                                                    work_id: retrieval_status.work_id,
                                                    source_id: retrieval_status.source_id,
                                                    total: item.fetch(:total, 0),
                                                    pdf: item.fetch(:pdf, nil),
                                                    html: item.fetch(:html, nil),
                                                    readers: item.fetch(:readers, nil),
                                                    comments: item.fetch(:comments, nil),
                                                    likes: item.fetch(:likes, nil)) }
  end

  def get_events_previous_day
    row = retrieval_status.days.last

    if row.nil?
      # first record
      { pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: 0 }
    elsif [row.year, row.month, row.day] == [today.year, today.month, today.day]
      # update today's record
      { pdf: retrieval_status.pdf - row.pdf,
        html: retrieval_status.html - row.html,
        readers: retrieval_status.readers - row.readers,
        comments: retrieval_status.comments - row.comments,
        likes: retrieval_status.likes - row.likes,
        total: retrieval_status.total - row.total }
    else
      # add record
      { pdf: retrieval_status.pdf,
        html: retrieval_status.html,
        readers: retrieval_status.readers,
        comments: retrieval_status.comments,
        likes: retrieval_status.likes,
        total: retrieval_status.total }
    end
  end

  # calculate events for current day based on past numbers
  # track daily events only the first 30 days after publication
  def get_events_current_day
    return nil if today - retrieval_status.work.published_on > 30

    row = get_events_previous_day

    { year: today.year,
      month: today.month,
      day: today.day,
      pdf: pdf - row.fetch(:pdf, 0),
      html: html - row.fetch(:html, 0),
      readers: readers - row.fetch(:readers, 0),
      comments: comments - row.fetch(:comments, 0),
      likes: likes - row.fetch(:likes, 0),
      total: total - row.fetch(:total, 0) }
  end

  def get_events_previous_month
    row = retrieval_status.months.last

    if row.nil?
      # first record
      { pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, total: 0 }
    elsif [row.year, row.month] == [today.year, today.month]
      # update this month's record
      { pdf: retrieval_status.pdf - row.pdf,
        html: retrieval_status.html - row.html,
        readers: retrieval_status.readers - row.readers,
        comments: retrieval_status.comments - row.comments,
        likes: retrieval_status.likes - row.likes,
        total: retrieval_status.total - row.total }
    else
      # add record
      { pdf: retrieval_status.pdf,
        html: retrieval_status.html,
        readers: retrieval_status.readers,
        comments: retrieval_status.comments,
        likes: retrieval_status.likes,
        total: retrieval_status.total }
    end
  end

  # calculate events for current month based on past numbers
  def get_events_current_month
    row = get_events_previous_month

    { year: today.year,
      month: today.month,
      pdf: pdf - row.fetch(:pdf, 0),
      html: html - row.fetch(:html, 0),
      readers: readers - row.fetch(:readers, 0),
      comments: comments - row.fetch(:comments, 0),
      likes: likes - row.fetch(:likes, 0),
      total: total - row.fetch(:total, 0) }
  end

  def not_error?
    status != :error
  end

  def success?
    status == :success
  end

  def skipped
    not_error? ? false : true
  end

  # dates via utc time are more accurate than Date.today
  def today
    Time.zone.now.to_date
  end

  def update_interval
    if [Date.new(1970, 1, 1), today].include?(previous_retrieved_at.to_date)
      1
    else
      (today - previous_retrieved_at.to_date).to_i
    end
  end

  def retrieved_at
    Time.zone.now
  end

  def to_hash
    { total: total,
      html: html,
      pdf: pdf,
      previous_total: previous_total,
      skipped: skipped,
      update_interval: update_interval }
  end
end
