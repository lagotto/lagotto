class Bitbucket < Source
  def get_query_url(work)
    return nil unless work.canonical_url =~ /bitbucket.org/

    # code from https://github.com/octokit/octokit.rb/blob/master/lib/octokit/repository.rb
    full_name = URI.parse(work.canonical_url).path[1..-1]
    owner, repo = full_name.split('/')

    url % { owner: owner, repo: repo }
  end

  def get_events_url(work)
    return nil unless work.canonical_url =~ /bitbucket.org/

    # code from https://github.com/octokit/octokit.rb/blob/master/lib/octokit/repository.rb
    full_name = URI.parse(work.canonical_url).path[1..-1]
    owner, repo = full_name.split('/')

    events_url % { owner: owner, repo: repo }
  end

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
end
