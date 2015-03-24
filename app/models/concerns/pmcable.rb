module Pmcable
  extend ActiveSupport::Concern

  included do
    def get_data(work, options={})
      query_url = get_query_url(work, options)
      if query_url.nil?
        result = {}
      else
        result = get_result(query_url, options)
        total = (result.fetch("hitCount", nil)).to_i

        if total > rows
          # walk through paginated results
          total_pages = (total.to_f / rows).ceil

          (2..total_pages).each do |page|
            options[:page] = page
            query_url = get_query_url(work, options)
            paged_result = get_result(query_url, options)
            result["#{result_key}List"][result_key] = result["#{result_key}List"][result_key] | paged_result.fetch("#{result_key}List", {}).fetch(result_key, [])
          end
        end
      end

      # extend hash fetch method to nested hashes
      result.extend Hashie::Extensions::DeepFetch
    end

    def parse_data(result, work, options={})
      return result if result[:error] || result["#{result_key}List"].nil?

      events = get_events(result, work)
      total = events.length
      events_url = total > 0 ? get_events_url(work) : nil

      { events: events,
        events_by_day: [],
        events_by_month: [],
        events_url: events_url,
        total: total,
        event_metrics: get_event_metrics(citations: total),
        extra: nil }
    end

    def get_events(result, work)
      result.fetch("#{result_key}List", {}).fetch(result_key, []).map do |item|
        doi = item.fetch("doi", nil)
        pmid = item.fetch(pmid_key, nil)
        url = doi ? "http://dx.doi.org/#{doi}" : "http://europepmc.org/abstract/MED/#{pmid}"
        author_string = item.fetch("authorString", "").chomp(".")

        { "author" => get_authors(author_string.split(", "), reversed: true),
          "title" => item.fetch("title", "").chomp("."),
          "container-title" => item.fetch(container_title_key, nil),
          "issued" => get_date_parts_from_parts(item.fetch("pubYear", nil)),
          "DOI" => doi,
          "PMID" => pmid,
          "URL" => url,
          "type" => "article-journal" }
      end
    end
  end
end
