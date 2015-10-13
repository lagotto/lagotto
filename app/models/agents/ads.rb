class Ads < Agent
  # include common methods for Article Coverage
  include Adsable

  def get_query_string(work)
    if work.doi.present?
      "\"doi:#{work.doi}\""
    else
      {}
    end
  end

  def get_related_works(result, work)
    result["response"] ||= {}
    Array(result["response"]["docs"]).map do |item|
      arxiv = item.fetch("identifier", []).find { |i| i =~ ARXIV_FORMAT }
      next unless arxiv.present?

      arxiv = arxiv.gsub(/\A\D*(\d{4}\.\d{4,5})D*/, '\1')
      url = "http://arxiv.org/abs/#{arxiv}"

      { "pid" => url,
        "author" => get_authors(item.fetch('author', []), reversed: true, sep: ", "),
        "title" => item.fetch("title", []).first.chomp("."),
        "container-title" => "ArXiV",
        "issued" => get_date_parts(item.fetch("pubdate", nil)),
        "URL" => url,
        "arxiv" => arxiv,
        "type" => "article-journal",
        "tracked" => tracked,
        "related_works" => [{ "pid" => work.pid,
                              "source_id" => name,
                              "relation_type_id" => "is_previous_version_of" }] }
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
