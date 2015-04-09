module Pmcable
  extend ActiveSupport::Concern

  included do
    def get_data(work, options={})
      query_url = get_query_url(work, options)
      return query_url if query_url.is_a?(Hash)

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

      # extend hash fetch method to nested hashes
      result.extend Hashie::Extensions::DeepFetch
    end

    def parse_data(result, work, options={})
      return result if result[:error] || result["#{result_key}List"].nil?

      related_works = get_related_works(result, work)
      total = related_works.length
      events_url = total > 0 ? get_events_url(work) : nil

    { works: related_works,
      metrics: {
        source: name,
        work: work.pid,
        total: total,
        events_url: events_url,
        days: get_events_by_day(related_works, work),
        months: get_events_by_month(related_works) } }
    end

    def get_related_works(result, work)
      result.fetch("#{result_key}List", {}).fetch(result_key, []).map do |item|
        pmid = item.fetch(pmid_key, nil)
        ids = get_persistent_identifiers(pmid, "pmid")
        ids = {} unless ids.is_a?(Hash)
        doi = ids.fetch("doi", nil)
        pmcid = ids.fetch("pmcid", nil)
        pmcid = pmcid[3..-1] if pmcid
        url = pmid ? "http://europepmc.org/abstract/MED/#{pmid}" : nil
        author_string = item.fetch("authorString", "").chomp(".")

        { "author" => get_authors(author_string.split(", "), reversed: true),
          "title" => item.fetch("title", "").chomp("."),
          "container-title" => item.fetch(container_title_key, nil),
          "issued" => get_date_parts_from_parts(item.fetch("pubYear", nil)),
          "DOI" => doi,
          "PMID" => pmid,
          "PMCID" => pmcid,
          "URL" => url,
          "type" => "article-journal",
          "related_works" => [{ "related_work" => work.pid,
                                "source" => name,
                                "relation_type" => "cites" }] }
      end
    end
  end
end
