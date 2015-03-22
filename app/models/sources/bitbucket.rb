class Bitbucket < Source
  # include common methods for repos
  include Repoable

  def parse_data(result, work, options={})
    return result if result[:error]

    shares = result.fetch("forks_count", 0)
    likes = result.fetch("followers_count", 0)
    total = shares + likes
    events = result.slice("followers_count", "forks_count", "description", "utc_created_on")
    events_url = total > 0 ? get_events_url(work) : nil

    { events: events,
      events_by_day: [],
      events_by_month: [],
      events_url: events_url,
      event_count: total,
      event_metrics: get_event_metrics(shares: shares, likes: likes, total: total) }
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    "https://api.bitbucket.org/1.0/repositories/%{owner}/%{repo}"
  end

  def events_url
    "https://bitbucket.org/%{owner}/%{repo}"
  end

  def rate_limiting
    config.rate_limiting || 30000
  end

  def repo_key
    "bitbucket.org"
  end

  def likes_key
    "followers_count"
  end

  def events_key
    ["followers_count", "forks_count", "description", "utc_created_on"]
  end
end
