class Twitter < Source
  def get_query_url(work)
    return nil unless work.doi =~ /^10.1371/

    url_private % { :doi => work.doi_escaped }
  end

  def response_options
    { :metrics => :comments }
  end

  def get_events(result)
    Array(result['rows']).map do |item|
      data = item['value']
      if data.key?("from_user")
        user = data["from_user"]
        user_name = data["from_user_name"]
        user_profile_image = data["profile_image_url"]
      else
        user = data["user"]["screen_name"]
        user_name = data["user"]["name"]
        user_profile_image = data["user"]["profile_image_url"]
      end

      timestamp = get_iso8601_from_time(data['created_at'])
      url = "http://twitter.com/#{user}/status/#{data['id_str']}"

      { "author" => get_authors([user_name]),
        "title" => data.fetch('text') { '' },
        "container-title" => 'Twitter',
        "issued" => get_date_parts(timestamp),
        "timestamp" => timestamp,
        "URL" => url,
        "type" => 'personal_communication' }
    end
  end

  def get_extra(result)
    Array(result['rows']).map do |item|
      data = item['value']
      if data.key?("from_user")
        user = data["from_user"]
        user_name = data["from_user_name"]
        user_profile_image = data["profile_image_url"]
      else
        user = data["user"]["screen_name"]
        user_name = data["user"]["name"]
        user_profile_image = data["user"]["profile_image_url"]
      end

      event_time = get_iso8601_from_time(data['created_at'])
      url = "http://twitter.com/#{user}/status/#{data['id_str']}"

      { event: { id: data.fetch("id_str", nil),
                 text: data.fetch("text", nil),
                 created_at: event_time,
                 user: user,
                 user_name: user_name,
                 user_profile_image: user_profile_image },
        event_time: event_time,
        event_url: url }
    end
  end

  def config_fields
    [:url_private]
  end
end
