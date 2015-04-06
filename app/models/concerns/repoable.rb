module Repoable
  extend ActiveSupport::Concern

  included do
    def get_query_url(work)
      get_url(work, "url")
    end

    def get_events_url(work)
      get_url(work, "events_url")
    end

    def get_url(work, common_url)
      return {} unless work.canonical_url =~ /#{repo_key}/

      # code from https://github.com/octokit/octokit.rb/blob/master/lib/octokit/repository.rb
      full_name = URI.parse(work.canonical_url).path[1..-1]
      owner, repo = full_name.split('/')

      send(common_url) % { owner: owner, repo: repo }
    end

    def parse_data(result, work, options={})
      return result if result[:error]

      readers = result.fetch("forks_count", 0)
      likes = result.fetch(likes_key, 0)
      total = readers + likes
      extra = result.slice(*events_key)
      events_url = total > 0 ? get_events_url(work) : nil

      { metrics: {
          source: name,
          work: work.pid,
          readers: readers,
          likes: likes,
          total: total,
          events_url: events_url,
          extra: extra } }
    end
  end
end
