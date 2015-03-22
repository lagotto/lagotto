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
      return nil unless work.canonical_url =~ /#{repo_key}/

      # code from https://github.com/octokit/octokit.rb/blob/master/lib/octokit/repository.rb
      full_name = URI.parse(work.canonical_url).path[1..-1]
      owner, repo = full_name.split('/')

      send(common_url) % { owner: owner, repo: repo }
    end
  end
end
