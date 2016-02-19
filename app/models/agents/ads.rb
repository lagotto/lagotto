class Ads < Agent
  # include common methods for ADS
  include Adsable

  def get_query_string(options = {})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return {} unless work.present? && work.doi.present?

    "\"doi:#{work.doi}\""
  end

  def get_relations_with_related_works(result, work)
    result["response"] ||= {}
    Array(result["response"]["docs"]).map do |item|
      arxiv = item.fetch("identifier", []).find { |i| Array(/(\d{4}\.\d{4,5})/.match(i)).last }

      next unless arxiv.present?

      arxiv_url = "http://arxiv.org/abs/#{arxiv}"

      { relation: { "subject" => arxiv_url,
                    "object" => work.pid,
                    "relation_type_id" => "is_previous_version_of",
                    "source_id" => name },
        work: { "pid" => arxiv_url,
                "author" => get_authors(item.fetch('author', []), reversed: true, sep: ", "),
                "title" => item.fetch("title", []).first.chomp("."),
                "container-title" => "ArXiV",
                "issued" => get_date_parts(item.fetch("pubdate", nil)),
                "URL" => arxiv_url,
                "arxiv" => arxiv,
                "type" => "article-journal",
                "tracked" => tracked } }
    end.compact
  end

  def url
    "https://api.adsabs.harvard.edu/v1/search/query?"
  end

  def events_url
    "https://ui.adsabs.harvard.edu/#search/q=body:%{query_string}"
  end

  def rate_limiting
    config.rate_limiting || 1000
  end

  def queue
    config.queue || "low"
  end
end
