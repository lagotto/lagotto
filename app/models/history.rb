class History
  # we can get data_from_source in 4 different formats
  # - hash with event_count nil: SKIPPED
  # - hash with event_count = 0: SUCCESS NO DATA
  # - hash with event_count > 0: SUCCESS
  # - nil                      : ERROR
  #
  # SKIPPED
  # The source doesn't know about the article identifier, and we never call the API.
  # Examples: mendeley, pub_med, counter, copernicus
  # We don't want to create a retrieval_history record, but should update retrieval_status
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

  attr_accessor :retrieval_status, :retrieval_history, :event_count, :previous_count, :previous_retrieved_at, :event_metrics, :events_url, :status, :couchdb_id, :rs_rev, :rh_rev, :data

  def initialize(rs_id, data = {})
    @retrieval_status = RetrievalStatus.find(rs_id)
    @previous_count = retrieval_status.event_count
    @previous_retrieved_at = retrieval_status.retrieved_at

    @status = case
      when data[:error] then :error
      when data[:event_count].nil? then :skipped
      when data[:event_count] > 0 then :success
      when data[:event_count] == 0 then :success_no_data
      end

    # data[:event_count] is nil on skipped articles, but we want to store 0
    @event_count = data[:event_count]
    @event_count = 0 if status == :skipped

    if not_error?
      # save data to retrieval_status table
      @event_metrics = data[:event_metrics] || get_event_metrics(citations: 0)
      @events_url = data[:events_url]

      retrieval_status.update_attributes(retrieved_at: retrieved_at,
                                         scheduled_at: retrieval_status.stale_at,
                                         event_count: event_count,
                                         event_metrics: event_metrics,
                                         events_url: events_url)
    end

    if ok?
      # save data to retrieval_history table
      @retrieval_history = retrieval_status.retrieval_histories.create(article_id: retrieval_status.article_id,
                                                                       source_id: retrieval_status.source_id,
                                                                       event_count: event_count,
                                                                       retrieved_at: retrieved_at)
    end

    if success?
      # save the data to couchdb
      @rs_rev = save_alm_data(couchdb_id, data: data.clone, source_id: retrieval_status.source_id)

      data[:doc_type] = "history"
      @rh_rev = save_alm_data(retrieval_history_id, data: data, source_id: retrieval_status.source_id)
    end
  end

  def not_error?
    status != :error
  end

  def ok?
    status == :success || status == :success_no_data
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
      doc_type: "current" }
  end

  def to_hash
    { event_count: event_count,
      previous_count: previous_count,
      retrieval_history_id: retrieval_history_id,
      update_interval: update_interval }
  end
end

# previous_count = event_count
#       if [Date.new(1970, 1, 1), Date.today].include?(retrieved_at.to_date)
#         update_interval = 1
#       else
#         update_interval = (Date.today - retrieved_at.to_date).to_i
#       end

#       result = source.get_data(article, timeout: source.timeout, source_id: source_id)
#       data_from_source = source.parse_data(result, article, source_id: source_id)
#       if data_from_source[:error]
#         return { event_count: nil, previous_count: previous_count, retrieval_history_id: nil, update_interval: update_interval }
#       else
#         events = data_from_source[:events]
#         events_url = data_from_source[:events_url]
#         event_count = data_from_source[:event_count]
#         event_metrics = data_from_source[:event_metrics]
#       end

#       retrieved_at = Time.zone.now

#       # SKIPPED
#       if event_count.nil?
#         update_attributes(retrieved_at: retrieved_at,
#                           scheduled_at: stale_at,
#                           event_count: 0)
#         { event_count: 0, previous_count: previous_count, retrieval_history_id: nil, update_interval: update_interval }
#       else
#         rh = RetrievalHistory.create(:retrieval_status_id => id,
#                                      :article_id => article_id,
#                                      :source_id => source_id)
#         # SUCCESS
#         if event_count > 0
#           data = { CONFIG[:uid].to_sym => article.uid,
#                    :retrieved_at => retrieved_at,
#                    :source => source.name,
#                    :events => events,
#                    :events_url => events_url,
#                    :event_metrics => event_metrics,
#                    :doc_type => "current" }

#           # save the data to mysql
#           update_attributes(retrieved_at: retrieved_at,
#                             scheduled_at: stale_at,
#                             event_count: event_count,
#                             event_metrics: event_metrics,
#                             events_url: events_url)
#           rh.update_attributes(event_count: event_count, retrieved_at: retrieved_at)

#           # save the data to couchdb
#           rs_rev = save_alm_data("#{source.name}:#{article.uid_escaped}", data: data.clone, source_id: source_id)

#           data[:doc_type] = "history"
#           rh_rev = save_alm_data(rh.id, data: data, source_id: source_id)

#         # SUCCESS NO DATA
#         else
#           # save the data to mysql, don't save any data to couchdb
#           update_attributes(retrieved_at: retrieved_at,
#                             scheduled_at: stale_at,
#                             event_count: 0,
#                             event_metrics: event_metrics,
#                             events_url: events_url)
#           rh.update_attributes(retrieved_at: retrieved_at, event_count: 0)
#         end

#         { event_count: event_count, previous_count: previous_count, retrieval_history_id: rh.id, update_interval: update_interval }
