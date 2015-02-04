class Mendeley < Source
  def parse_data(result, work, options={})
    return result if result[:error].is_a?(String)

    result = result.fetch("data", []).first || {}

    readers = result.fetch("reader_count", 0)
    groups = result.fetch("group_count", 0)
    total = readers + groups
    events_url = result.fetch("link", nil)

    { events: result,
      events_by_day: [],
      events_by_month: [],
      events_url: events_url,
      event_count: total,
      event_metrics: get_event_metrics(shares: readers, groups: groups, total: total) }
  end

  def get_query_url(work)
    # First check that we have a valid OAuth2 access token, and a refreshed uuid
    return nil unless get_access_token && (work.doi.present? || work.pmid.present? || work.scp.present?)

    if work.doi.present?
      query_string = "doi=#{work.doi}"
    elsif work.pmid.present?
      query_string = "pmid=#{work.pmid}"
    else
      query_string = "scopus=#{work.scp}"
    end

    url % { :query_string => query_string }
  end

  def get_access_token(options={})
    # Check whether access token is valid for at least another 5 minutes
    return true if access_token.present? && (Time.zone.now + 5.minutes < expires_at.to_time.utc)

    # Otherwise get new access token
    result = get_result(authentication_url, options.merge(
      username: client_id,
      password: client_secret,
      data: "grant_type=client_credentials",
      source_id: id,
      headers: { "Content-Type" => "application/x-www-form-urlencoded;charset=UTF-8" }))

    if result.present? && result["access_token"] && result["expires_in"]
      config.expires_at = Time.zone.now + result["expires_in"].seconds
      config.access_token = result["access_token"]
      save
    else
      false
    end
  end

  def request_options
    { bearer: access_token }
  end

  # Format Mendeley events for all works as csv
  def to_csv(options = {})
    service_url = "#{ENV['COUCHDB_URL']}/_design/reports/_view/mendeley"

    result = get_result(service_url, options.merge(timeout: 1800))
    if result.blank? || result["rows"].blank?
      Alert.create(exception: "", class_name: "Faraday::ResourceNotFound",
                   message: "CouchDB report for Mendeley could not be retrieved.",
                   status: 404,
                   source_id: id,
                   level: Alert::FATAL)
      return nil
    end

    CSV.generate do |csv|
      csv << ["pid_type", "pid", "readers", "groups", "total"]
      result["rows"].each { |row| csv << ["doi", row["key"], row["value"]["readers"], row["value"]["groups"], row["value"]["readers"] + row["value"]["groups"]] }
    end
  end

  def config_fields
    [:url, :authentication_url, :client_id, :client_secret, :access_token, :expires_at]
  end

  def url
    config.url || "https://api.mendeley.com/catalog?%{query_string}&view=stats"
  end

  def authentication_url
    config.authentication_url || "https://api.mendeley.com/oauth/token"
  end
end
