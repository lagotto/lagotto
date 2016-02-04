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

    def parse_data(result, options={})
      work = Work.where(id: options.fetch(:work_id, nil)).first
      return {} unless work.present?
      return result if result[:error]

      query_url = get_query_url(work)
      result["stargazers"] = get_result(query_url + "/stargazers", options) unless query_url.is_a?(Hash)
      related_works = get_related_works(result, work)
      readers = related_works.count
      total = readers + result.fetch("forks_count", 0)
      extra = result.slice(*events_key)
      events_url = total > 0 ? get_events_url(work) : nil

      { works: related_works,
        events: [{
          source_id: name,
          work_id: work.pid,
          readers: readers,
          total: total,
          events_url: events_url,
          extra: extra,
          days: get_events_by_day(related_works, work.published_on, options.merge(metrics: :readers)),
          months: get_events_by_month(related_works, options.merge(metrics: :readers)) }.compact] }
    end

    def get_related_works(result, work)
      result["stargazers"] = nil if result["stargazers"].is_a?(Hash)
      Array(result.fetch("stargazers", nil)).map do |item|
        author = item.fetch("login", nil)
        timestamp = Time.zone.now.utc.iso8601
        url = item.fetch("html_url", nil)

        { "author" => get_authors([author]),
          "title" => "#{title} user #{author}",
          "container-title" => "#{title}",
          "issued" => get_date_parts(timestamp),
          "timestamp" => timestamp,
          "URL" => url,
          "type" => 'entry',
          "tracked" => tracked,
          "registration_agency" => name,
          "related_works" => [{ "related_work" => work.pid,
                                "source" => name,
                                "relation_type" => "bookmarks" }] }
      end
    end
  end
end
