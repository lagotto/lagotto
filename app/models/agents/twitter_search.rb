class TwitterSearch < Agent
  def request_options
    { bearer: access_token, agent_id: id }
  end

  def get_query_url(options = {})
    query_string = get_query_string(options)
    return {} unless query_string.present?
    fail ArgumentError, "No access token." unless get_access_token

    url % { query_string: query_string }
  end

  def get_query_string(options = {})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return {} unless work.present? && (work.get_url || work.doi.present?)

    [work.doi, work.canonical_url].compact.map { |i| "%22#{i}%22" }.join("+OR+")
  end

  def get_relations_with_related_works(result, work)
    provenance_url = get_provenance_url(work_id: work.id)

    Array(result['statuses']).map do |item|
      if item.key?("from_user")
        user = item["from_user"]
        user_name = item["from_user_name"]
      else
        user = item["user"]["screen_name"]
        user_name = item["user"]["name"]
      end

      url = "http://twitter.com/#{user}/status/#{item.fetch('id_str', '')}"

      { prefix: work.prefix,
        relation: { "subj_id" => url,
                    "obj_id" => work.pid,
                    "relation_type_id" => "discusses",
                    "provenance_url" => provenance_url,
                    "source_id" => source_id },
        subj: { "pid" => url,
                "author" => get_authors([user_name]),
                "title" => item.fetch('text', ''),
                "container-title" => 'Twitter',
                "issued" => get_iso8601_from_time(item.fetch('created_at', nil)),
                "URL" => url,
                "type" => 'personal_communication',
                "tracked" => tracked,
                "registration_agency_id" => "twitter" }}
    end
  end

  def get_access_token(options={})
    # Check whether we already have an access token
    return true if access_token.present?

    # Otherwise get new access token
    result = get_result(authentication_url, options.merge(
      content_type: 'html',
      username: api_key,
      password: api_secret,
      data: "grant_type=client_credentials",
      source_id: source_id,
      headers: { "Content-Type" => "application/x-www-form-urlencoded;charset=UTF-8" }))

    if result.present? && result["access_token"]
      config.access_token = result["access_token"]
      save
    else
      false
    end
  end

  def config_fields
    [:url, :provenance_url, :authentication_url, :api_key, :api_secret, :access_token]
  end

  def url
    "https://api.twitter.com/1.1/search/tweets.json?q=%{query_string}&count=100&include_entities=1&result_type=recent"
  end

  def provenance_url
    "https://twitter.com/search?q=%{query_string}&f=realtime"
  end

  def authentication_url
    "https://api.twitter.com/oauth2/token"
  end

  def cron_line
    config.cron_line || "* 6 * * *"
  end

  def job_batch_size
    config.job_batch_size || 100
  end

  def rate_limiting
    config.rate_limiting || 1800
  end

  def source_id
    "twitter"
  end

  def queue
    config.queue || "low"
  end
end
