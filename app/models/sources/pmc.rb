# encoding: UTF-8

class Pmc < Source
  def parse_data(result, work, options={})
    # properly handle not found errors
    result = { 'data' => [] } if result[:status] == 404

    return result if result[:error]

    events = Array(result["views"])

    pdf = get_sum(events, 'pdf')
    html = get_sum(events, 'full-text')
    total = pdf + html
    events_url = total > 0 ? get_events_url(work) : nil

    { events: events,
      events_by_day: [],
      events_by_month: get_events_by_month(events),
      events_url: events_url,
      event_count: total,
      event_metrics: get_event_metrics(pdf: pdf, html: html, total: total) }
  end

  def get_events_by_month(events)
    events.map do |event|
      { month: event['month'].to_i,
        year: event['year'].to_i,
        html: event['full-text'].to_i,
        pdf: event['pdf'].to_i }
    end
  end

  # Retrieve usage stats in XML and store in /data directory. Returns an empty array if no error occured
  def get_feed(month, year, options={})
    journals_with_errors = []
    options[:source_id] = id

    publisher_configs.each do |publisher|
      publisher_id = publisher[0]
      journals_array = publisher[1].journals.to_s.split(" ")

      journals_array.each do |journal|
        feed_url = get_feed_url(publisher_id, month, year, journal)
        filename = "pmcstat_#{journal}_#{month}_#{year}.xml"

        next if save_to_file(feed_url, filename, options)

        message = "PMC Usage stats for journal #{journal}, month #{month}, year #{year} could not be saved"
        Alert.where(message: message).where(unresolved: true).first_or_create(
          :exception => "",
          :class_name => "Net::HTTPInternalServerError",
          :status => 500,
          :source_id => id)
        journals_with_errors << journal
      end
    end
    journals_with_errors
  end

  # Parse usage stats and store in CouchDB. Returns an empty array if no error occured
  def parse_feed(month, year, _options = {})
    journals_with_errors = []

    publisher_configs.each do |publisher|
      pc = publisher[1]
      next if pc.username.nil? || pc.password.nil?

      journals_array = pc.journals.to_s.split(" ")

      journals_array.each do |journal|
        filename = "pmcstat_#{journal}_#{month}_#{year}.xml"
        file = File.open("#{Rails.root}/data/#{filename}", 'r') { |f| f.read }
        document = Nokogiri::XML(file)

        status = document.at_xpath("//pmc-web-stat/response/@status").value
        if status != "0"
          error_message = document.at_xpath("//pmc-web-stat/response/error").content
          message = "PMC Usage stats for journal #{journal}, month #{month} and year #{year}: #{error_message}"
          Alert.where(message: message).where(unresolved: true).first_or_create(
            :exception => "",
            :class_name => "Net::HTTPInternalServerError",
            :status => 500,
            :source_id => id)
          journals_with_errors << journal
        else
          # go through all the works in the xml document
          document.xpath("//work").each do |work|
            work = work.to_hash
            work = work["work"]

            doi = work["meta-data"]["doi"]
            # sometimes doi metadata are missing
            break unless doi

            view = work["usage"]
            view['year'] = year.to_s
            view['month'] = month.to_s

            # try to get the existing information about the given work
            data = get_result(url_db + CGI.escape(doi))

            if data['views'].nil?
              data = { 'views' => [view] }
            else
              # update existing entry
              data['views'].delete_if { |view| view['month'] == month.to_s && view['year'] == year.to_s }
              data['views'] << view
            end

            put_lagotto_data(url_db + CGI.escape(doi), data: data)
          end
        end
      end
    end
    journals_with_errors
  end

  def put_database
    put_lagotto_data(url_db)
  end

  def get_feed_url(publisher_id, month, year, journal)
    # check that we have publisher-specific configuration
    pc = publisher_config(publisher_id)
    return nil if pc.username.nil? || pc.password.nil?

    feed_url % { year: year, month: month, journal: journal, username: pc.username, password: pc.password }
  end

  def get_events_url(work)
    events_url % { :pmcid => work.pmcid } if work.pmcid.present?
  end

  def url
    url_db + "%{doi}"
  end

  def config_fields
    [:url_db, :feed_url, :events_url, :journals, :username, :password]
  end

  def feed_url
    "http://www.pubmedcentral.nih.gov/utils/publisher/pmcstat/pmcstat.cgi?year=%{year}&month=%{month}&jrid=%{journal}&user=%{username}&password=%{password}"
  end

  def events_url
    "http://www.ncbi.nlm.nih.gov/pmc/works/PMC%{pmcid}"
  end

  def cron_line
    config.cron_line || "0 5 9 * *"
  end

  def by_publisher?
    true
  end
end
