class Github < Source
  # include common methods for repos
  include Repoable

  def request_options
    { bearer: personal_access_token }
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

  def likes_key
    "stargazers_count"
  end

  def events_key
    ["stargazers_count", "stargazers_url", "forks_count", "forks_url"]
  end
end
