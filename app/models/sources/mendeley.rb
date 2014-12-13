# encoding: UTF-8

class Mendeley < Source
  def parse_data(result, work, options={})
    # When Mendeley doesn't return a proper API response it can return
    # - a 404 status and error hash
    # - an empty array
    # - an incomplete hash with just the Mendeley uuid
    # We should handle all 3 cases, but return an error otherwise
    return result if result[:error].is_a?(String)

    events = result.fetch('stats') { {} }

    readers = result.deep_fetch('stats', 'readers') { 0 }
    groups = Array(result['groups']).length
    total = readers + groups

    { events: events,
      events_by_day: [],
      events_by_month: [],
      events_url: result['mendeley_url'],
      event_count: total,
      event_metrics: get_event_metrics(shares: readers, groups: groups, total: total) }
  end

  def get_mendeley_uuid(work, options={})
    # get Mendeley uuid, try pmid first, then doi
    # Otherwise search by title
    # Only use uuid if we also get mendeley_url, otherwise the uuid is broken and we return nil
    # The Mendeley uuid is not persistent, so we need to get it every time

    unless work.pmid.blank?
      result = get_result(get_lookup_url(work), options.merge(bearer: access_token))
      if result.is_a?(Hash) && result['mendeley_url']
        work.update_attributes(:mendeley_uuid => result['uuid'])
        return result['uuid']
      end
    end

    unless work.doi.nil?
      result = get_result(get_lookup_url(work, "doi"), options.merge(bearer: access_token))
      if result.is_a?(Hash) && result['mendeley_url']
        work.update_attributes(:mendeley_uuid => result['uuid'])
        return result['uuid']
      end
    end

    # search by title if we can't get the uuid using the pmid or doi
    unless work.title.blank?
      results = get_result(get_lookup_url(work, "title"), options.merge(bearer: access_token))
      if results.is_a?(Hash) && results['documents']
        documents = results["documents"].select { |document| document["doi"] == work.doi }
        if documents && documents.length == 1 && documents[0]['mendeley_url']
          work.update_attributes(:mendeley_uuid => documents[0]['uuid'])
          return documents[0]['uuid']
        end
      end
    end

    # return nil if we can't get the correct uuid
    nil
  end

  def get_query_url(work)
    # First check that we have a valid OAuth2 access token, and a refreshed uuid
    return nil unless get_access_token && get_mendeley_uuid(work)

    url % { :id => work.mendeley_uuid, :api_key => api_key }
  end

  def get_lookup_url(work, id_type = 'pmid')
    # First check that we have a valid OAuth2 access token
    return nil unless get_access_token

    case id_type
    when "pmid"
      url_with_type % { :id => work.pmid, :doc_type => id_type, :api_key => api_key }
    when "doi"
      url_with_type % { :id => CGI.escape(work.doi_escaped), :doc_type => id_type, :api_key => api_key }
    when "title"
      url_with_title % { :title => CGI.escape("title:#{work.title}"), :api_key => api_key }
    else
      nil
    end
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
    [:url, :url_with_type, :url_with_title, :authentication_url, :client_id, :client_secret, :access_token, :expires_at]
  end

  def url
    config.url || "https://api-oauth2.mendeley.com/oapi/documents/details/%{id}"
  end

  def url_with_type
    config.url_with_type || "https://api-oauth2.mendeley.com/oapi/documents/details/%{id}/?type=%{doc_type}"
  end

  def url_with_type=(value)
    config.url_with_type = value
  end

  def url_with_title
    config.url_with_title || "https://api-oauth2.mendeley.com/oapi/documents/search/title:%{title}/?items=10"
  end

  def url_with_title=(value)
    config.url_with_title = value
  end

  def authentication_url
    config.authentication_url || "https://api-oauth2.mendeley.com/oauth/token"
  end
end
