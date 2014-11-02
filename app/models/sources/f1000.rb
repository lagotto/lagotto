# encoding: UTF-8

class F1000 < Source
  def parse_data(result, article)
    # properly handle not found errors
    result = { 'data' => [] } if result[:status] == 404

    return result if result[:error]

    events = get_events(result)

    if events.empty?
      event_count = 0
      events_url = nil
    else
      event = events.last[:event]
      event_count = event['score']
      events_url = event['url']
    end

    { events: events,
      events_by_day: [],
      events_by_month: get_events_by_month(events),
      events_url: events_url,
      event_count: event_count,
      event_metrics: get_event_metrics(citations: event_count) }
  end

  def get_events(result)
    result['recommendations'] ||= {}
    Array(result['recommendations']).map do |item|
      { :event => item,
        :event_url => item['url'] }
    end
  end

  # Retrieve f1000 XML feed and store in /data directory.
  def get_feed(options={})
    save_to_file(feed_url, filename, options.merge(source_id: id))
  end

  def get_events_by_month(events)
    events.map do |event|
      { month: event[:event]['month'],
        year: event[:event]['year'],
        total: event[:event]['score'] }
    end
  end

  # Parse f1000 feed and store in CouchDB. Returns an empty array if no error occured
  def parse_feed(options={})
    document = read_from_file(filename)
    document.extend Hashie::Extensions::DeepFetch
    recommendations = document.deep_fetch('ObjectList', 'Article') { nil }

    Array(recommendations).each do |item|
      doi = item['Doi']
      # sometimes doi metadata are missing
      break unless doi

      # turn classifications into array with lowercase letters
      classifications = item['Classifications'] ? item['Classifications'].downcase.split(", ") : []

      year = Time.zone.now.year
      month = Time.zone.now.month

      recommendation = { 'year' => year,
                         'month' => month,
                         'doi' => doi,
                         'f1000_id' => item['Id'],
                         'url' => item['Url'],
                         'score' => item['TotalScore'].to_i,
                         'classifications' => classifications,
                         'updated_at' => Time.now.utc.iso8601 }

      # try to get the existing information about the given article
      data = get_result(db_url + CGI.escape(doi))

      if data['recommendations'].nil?
        data = { 'recommendations' => [recommendation] }
      else
        # update existing entry
        data['recommendations'].delete_if { |recommendation| recommendation['month'] == month && recommendation['year'] == year }
        data['recommendations'] << recommendation
      end

      # store updated information in CouchDB
      put_lagotto_data(db_url + CGI.escape(doi), data: data)
    end
  end

  def put_database
    put_lagotto_data(db_url)
  end

  def get_feed_url
    feed_url
  end

  def filename
    String(feed_url).split("/").last
  end

  def url
    db_url + "%{doi}"
  end

  def config_fields
    [:db_url, :feed_url]
  end

  def cron_line
    config.cron_line || "* 02 * * 1"
  end
end
