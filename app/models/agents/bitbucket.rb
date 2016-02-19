class Bitbucket < Agent
  # include common methods for repos
  include Repoable

  def parse_data(result, options={})
    return result if result[:error]
    work = Work.where(id: options[:work_id]).first
    return { error: "Resource not found.", status: 404 } unless work.present?

    # TODO forks = readers?
    # readers = result.fetch("forks_count", 0)
    # likes = result.fetch("followers_count", 0)
    # total = readers + likes
    # extra = result.slice("followers_count", "forks_count", "description", "utc_created_on")
    # events_url = total > 0 ? get_events_url(work_id: work.id) : nil

    # { events: [{
    #     source_id: name,
    #     work_id: work.pid,
    #     readers: readers,
    #     likes: likes,
    #     total: total,
    #     events_url: events_url,
    #     extra: extra }] }

        [{"subject" => "http://bitbucket.org",
          "object" => work.pid,
          "relation" => "reads",
          "total" => result.fetch("followers_count", 0),
          "source" => name},
        { "subject" => "http://bitbucket.org",
          "object" => work.pid,
          "relation" => "forks",
          "total" => result.fetch("forks_count", 0),
          "source" => name}]
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
