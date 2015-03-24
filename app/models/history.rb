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

    @pdf = data.fetch(:pdf, nil)
    @html = data.fetch(:html, nil)
    @readers = data.fetch(:readers, nil)
    @comments = data.fetch(:comments, nil)
    @likes = data.fetch(:likes, nil)
    @total = data.fetch(:total, nil).to_i

    @extra = data.fetch(:extra, nil)

    if not_error?
      @event_metrics = data[:event_metrics] || get_event_metrics(citations: 0)
      @events_url = data[:events_url]

      save_to_retrieval_statuses
    end

    if success?
      @works = Array(data[:events])

      @events_by_day = data[:events_by_day]
      @events_by_day = get_events_by_day if events_by_day.blank?

      @events_by_month = data[:events_by_month]
      @events_by_month = get_events_by_month if events_by_month.blank?

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
                                                total: item[:total],
                                                pdf: item[:pdf],
                                                html: item[:html],
                                                readers: item[:readers],
                                                comments: item[:comments],
                                                likes: item[:likes]) }
  end

  def save_to_months
    Array(events_by_month).map { |item| Month.where(retrieval_status_id: retrieval_status.id,
                                                    month: item[:month],
                                                    year: item[:year]).first_or_create(
                                                    work_id: retrieval_status.work_id,
                                                    source_id: retrieval_status.source_id,
                                                    total: item[:total],
                                                    pdf: item[:pdf],
                                                    html: item[:html],
                                                    readers: item[:readers],
                                                    comments: item[:comments],
                                                    likes: item[:likes]) }
  end

  def get_events_by_day
    # track daily events only the first 30 days after publication
    return nil if today - retrieval_status.work.published_on > 30

    hsh = get_new_events(retrieval_status.days.past)
    [hsh.merge(year: today.year, month: today.month, day: today.day)]
  end

  def get_events_by_month
    hsh = get_new_events(retrieval_status.months.past)
    [hsh.merge(year: today.year, month: today.month)]
  end

  def get_new_events(rows)
    { pdf: pdf.nil? ? nil : pdf - rows.sum(:pdf),
      html: html.nil? ? nil : html - rows.sum(:html),
      readers: readers.nil? ? nil : readers - rows.sum(:readers),
      comments: comments.nil? ? nil : comments - rows.sum(:comments),
      likes: likes.nil? ? nil : likes - rows.sum(:likes),
      total: total.nil? ? nil : total - rows.sum(:total) }.compact
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
