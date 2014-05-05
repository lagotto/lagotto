class History
  # we can get data_from_source in 3 different formats
  # - hash with event_count = 0: SUCCESS NO DATA
  # - hash with event_count > 0: SUCCESS
  # - hash with error          : ERROR
  #
  # SUCCESS NO DATA
  # The source knows about the article identifier, but returns an event_count of 0
  #
  # SUCCESS
  # The source knows about the article identifier, and returns an event_count > 0
  #
  # ERROR
  # An error occured, typically 408 (Request Timeout), 403 (Too Many Requests) or 401 (Unauthorized)
  # It could also be an error in our code. 404 (Not Found) errors are handled as SUCCESS NO DATA
  # We don't update retrieval status and don't create a retrieval_histories document,
  # so that the request is repeated later. We could get stuck, but we see this in alerts
  #
  # This class returns a hash in the format event_count: 12, previous_count: 8, retrieval_history_id: 3736, update_interval: 31
  # This hash can be used to track API responses, e.g. when event counts go down

  # include HTTP request helpers
  include Networkable

  # include CouchDB helpers
  include Couchable

  # include metrics helpers
  include Measurable

  attr_accessor :retrieval_status, :retrieval_history, :events, :event_count, :previous_count, :previous_retrieved_at, :previous_events_by_day, :previous_events_by_month, :event_metrics, :events_by_day, :events_by_month, :events_url, :status, :couchdb_id, :rs_rev, :rh_rev, :data

  def initialize(rs_id, data = {})
    @retrieval_status = RetrievalStatus.find(rs_id)
    @previous_count = retrieval_status.event_count
    @previous_retrieved_at = retrieval_status.retrieved_at

    @status = case
              when data[:error] then :error
              when data[:event_count] > 0 then :success
              when data[:event_count] == 0 then :success_no_data
              end

    @event_count = data[:event_count]

    if not_error?
      @event_metrics = data[:event_metrics] || get_event_metrics(citations: 0)
      @events_url = data[:events_url]

      save_to_mysql
    end

    if success?
      @events = data[:events]
      @events_by_day = data[:events_by_day]
      @events_by_month = data[:events_by_month]

      save_to_couchdb
    end
  end

  def save_to_mysql
    # save data to retrieval_status table
    retrieval_status.update_attributes(retrieved_at: retrieved_at,
                                       scheduled_at: retrieval_status.stale_at,
                                       event_count: event_count,
                                       event_metrics: event_metrics,
                                       events_url: events_url)

    # save data to retrieval_history table
    @retrieval_history = retrieval_status.retrieval_histories.create(article_id: retrieval_status.article_id,
                                                                     source_id: retrieval_status.source_id,
                                                                     event_count: event_count,
                                                                     retrieved_at: retrieved_at)
  end

  def save_to_couchdb
    if events_by_day.blank? || events_by_month.blank?
      # check for existing couchdb document
      data_rev = get_alm_rev(couchdb_id)

      if data_rev.present?
        previous_data = get_alm_data(couchdb_id)
        previous_data = {} if previous_data.nil? || previous_data['error']
      else
        previous_data = {}
      end

      @events_by_day = get_events_by_day(previous_data['events_by_day']) if events_by_day.blank?
      @events_by_month = get_events_by_month(previous_data['events_by_month']) if events_by_month.blank?

      options = { data: data.clone }
      options[:data][:_id] = "#{couchdb_id}"
      options[:data][:_rev] = data_rev if data_rev.present?

      @rs_rev = put_alm_data("#{CONFIG[:couchdb_url]}#{couchdb_id}", options)
    else
      # only save the data to couchdb
      @rs_rev = save_alm_data(couchdb_id, data: data.clone, source_id: retrieval_status.source_id)
    end

    @rs_rev = save_alm_data(couchdb_id, data: data.clone, source_id: retrieval_status.source_id)

    data[:doc_type] = "history"
    @rh_rev = save_alm_data(retrieval_history_id, data: data, source_id: retrieval_status.source_id)
  end

  def get_events_by_day(event_arr = nil)
    event_arr = Array(event_arr)

    # track daily events only the first 30 days after publication
    # dates via utc time are more accurate than Date.today
    today = Time.zone.now.to_date

    # return entry for older articles
    return event_arr if today - retrieval_status.article.published_on > 30

    # update today's entry for recent articles
    event_arr.delete_if { |item| item['day'] == today.day && item['month'] == today.month && item['year'] == today.year }
    if ['counter', 'pmc'].include?(retrieval_status.source.name)
      item = { 'year' => today.year,
               'month' => today.month,
               'day' => today.day,
               'html' => event_metrics[:html],
               'pdf' => event_metrics[:pdf] }
    else
      item = { 'year' => today.year,
               'month' => today.month,
               'day' => today.day,
               'total' => event_count }
    end

    event_arr << item
  end

  def get_events_by_month(event_arr = nil)
    event_arr = Array(event_arr)

    # dates via utc time are more accurate than Date.today
    today = Time.zone.now.to_date

    # update this month's entry
    event_arr.delete_if { |item| item['month'] == today.month && item['year'] == today.year }
    event_arr << { 'year' => today.year,
                   'month' => today.month,
                   'total' => event_count }
  end

  def not_error?
    status != :error
  end

  def success?
    status == :success
  end

  def couchdb_id
    "#{retrieval_status.source.name}:#{retrieval_status.article.uid_escaped}"
  end

  def retrieval_history_id
    retrieval_history ? retrieval_history.id : nil
  end

  def update_interval
    if [Date.new(1970, 1, 1), Date.today].include?(previous_retrieved_at.to_date)
      1
    else
      (Date.today - previous_retrieved_at.to_date).to_i
    end
  end

  def retrieved_at
    Time.zone.now
  end

  def data
    { CONFIG[:uid].to_sym => retrieval_status.article.uid,
      retrieved_at: retrieved_at,
      source: retrieval_status.source.name,
      events: events,
      events_url: events_url,
      event_metrics: event_metrics,
      events_by_day: events_by_day,
      events_by_month: events_by_month,
      doc_type: "current" }
  end

  def to_hash
    { event_count: event_count,
      previous_count: previous_count,
      retrieval_history_id: retrieval_history_id,
      update_interval: update_interval }
  end
end
