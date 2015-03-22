class Github < Source
  # include common methods for repos
  include Repoable

  def request_options
    { bearer: personal_access_token }
  end

  def parse_data(result, work, options={})
    return result if result[:error]

    shares = result.fetch("forks_count", 0)
    likes = result.fetch("stargazers_count", 0)
    total = shares + likes
    events = result.slice("stargazers_count", "stargazers_url", "forks_count", "forks_url")
    events_url = total > 0 ? get_events_url(work) : nil

    { events: events,
      events_by_day: [],
      events_by_month: [],
      events_url: events_url,
      event_count: total,
      event_metrics: get_event_metrics(shares: shares, likes: likes, total: total) }
  end

  def config_fields
    [:url, :events_url, :personal_access_token]
  end

  def url
    "https://api.github.com/repos/%{owner}/%{repo}"
  end

  def events_url
    "https://github.com/%{owner}/%{repo}"
  end

  # More info at https://github.com/blog/1509-personal-api-tokens
  def personal_access_token
    config.personal_access_token
  end

  def personal_access_token=(value)
    config.personal_access_token = value
  end

  def rate_limiting
    config.rate_limiting || 5000
  end

  def repo_key
    "github.com"
  end
end
