class Pmc < Source
  def get_query_url(work)
    return {} unless work.doi.present?
    fail ArgumentError, "Source url is missing." if url.blank?

    url % { doi: work.doi_escaped }
  end

  def parse_data(result, work, options={})
    # properly handle not found errors
    result = { 'data' => [] } if result[:status] == 404

    return result if result[:error]

    extra = Array(result["views"])
    html = get_sum(extra, 'full-text')
    pdf = get_sum(extra, 'pdf')
    total = html + pdf
    events_url = total > 0 ? get_events_url(work) : nil

    { events: {
        source: name,
        work: work.pid,
        pdf: pdf,
        html: html,
        total: total,
        events_url: events_url,
        extra: extra,
        months: get_events_by_month(extra) } }
  end

  def get_events_by_month(extra)
    extra.map do |event|
      html = event['full-text'].to_i
      pdf = event['pdf'].to_i

      { month: event['month'].to_i,
        year: event['year'].to_i,
        html: html,
        pdf: pdf,
        total: html + pdf }
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
        status = parse_file(filename, month, year)
        journals_with_errors << journal if status != "0"
      end
    end
    journals_with_errors
  end

  def parse_file(filename, month, year)
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
    else
      # go through all the works in the xml document
      document.xpath("//article").each do |work|
        response = parse_work(work, month, year)
        next unless response[:doi].present?

        put_work(response[:doi], response[:data])
      end
    end
    status
  end

  def parse_work(work, month, year)
    work = work.to_hash
    work = work["article"]

    doi = work.fetch("meta-data", {}).fetch("doi", nil)
    # sometimes doi metadata are missing
    return { doi: nil, data: nil } unless doi.present?

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
    { doi: doi, data: data }
  end

  def put_work(doi, data)
    put_lagotto_data(url_db + doi, data: data)
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
