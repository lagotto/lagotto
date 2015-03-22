class TwitterSearch < Source
  def request_options
    { bearer: access_token }
  end

  def get_query_url(work, options = {})
    return nil unless get_access_token

    query_string = get_query_string(work)
    return nil unless url.present? && query_string.present?

    url % { query_string: query_string }
  end

  def parse_data(result, work, options={})
    # return early if an error occured
    return result if result[:error]

    events = get_events(result)
    events = update_events(work, events)

    { events: events,
      events_by_day: get_events_by_day(events, work),
      events_by_month: get_events_by_month(events),
      events_url: get_events_url(work),
      event_count: events.length,
      event_metrics: get_event_metrics(:comments => events.length) }
  end

  def get_events(result)
    Array(result['statuses']).map do |item|
      if item.key?("from_user")
        user = item["from_user"]
        user_name = item["from_user_name"]
        user_profile_image = item["profile_image_url"]
      else
        user = item["user"]["screen_name"]
        user_name = item["user"]["name"]
        user_profile_image = item["user"]["profile_image_url"]
      end

      event_time = get_iso8601_from_time(item['created_at'])
      url = "http://twitter.com/#{user}/status/#{item['id_str']}"

      { event: { id: item["id_str"],
                 text: item["text"],
                 created_at: event_time,
                 user: user,
                 user_name: user_name,
                 user_profile_image: user_profile_image },
        event_time: event_time,
        event_url: url,

        # the rest is CSL (citation style language)
        event_csl: {
          'author' => get_authors([user_name]),
          'title' => item.fetch('text', ""),
          'container-title' => 'Twitter',
          'issued' => get_date_parts(event_time),
          'url' => url,
          'type' => 'personal_communication'
        }
      }
    end
  end

  # check whether we have stored additional tweets in the past
  # merge with new tweets, using tweet URL as unique key
  # we need hash with indifferent access to compare string and symbol keys
  def update_events(work, events)
    data = HashWithIndifferentAccess.new(get_lagotto_data("twitter_search:#{work.doi_escaped}"))

    merged_events = Array(data['events']) | events
    merged_events.group_by { |event| event[:event][:id] }.map { |_, v| v.first }
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
      source_id: id,
      headers: { "Content-Type" => "application/x-www-form-urlencoded;charset=UTF-8" }))

    if result.present? && result["access_token"]
      config.access_token = result["access_token"]
      save
    else
      false
    end
  end

  def config_fields
    [:url, :events_url, :authentication_url, :api_key, :api_secret, :access_token]
  end

  def url
    "https://api.twitter.com/1.1/search/tweets.json?q=%{query_string}&count=100&include_entities=1&result_type=recent"
  end

  def events_url
    "https://twitter.com/search?q=%{query_string}&f=realtime"
  end

  def authentication_url
    "https://api.twitter.com/oauth2/token"
  end

  def job_batch_size
    config.job_batch_size || 100
  end

  def rate_limiting
    config.rate_limiting || 1600
  end

  def staleness_week
    config.staleness_week || 1.day
  end

  def staleness_month
    config.staleness_month || 1.day
  end

  def staleness_year
    config.staleness_year || (1.month * 0.25).to_i
  end

  def staleness_all
    config.staleness_all || (1.month * 0.25).to_i
  end
end
