class AdsFulltext < Source
  # include common methods for Article Coverage
  include Adsable

  def get_query_string(work)
    if work.doi.present?
      "\"body:#{work.doi}\""
    elsif work.canonical_url.present?
      "\"body:#{work.canonical_url}\""
    else
      {}
    end
  end

  def get_related_works(result, work)
    result["response"] ||= {}
    Array(result["response"]["docs"]).map do |item|
      arxiv = item.fetch("identifier", []).find { |i| i.starts_with?("arXiv:") }
      next unless arxiv.present?

      arxiv = arxiv.gsub(/\A\D*(\d{4}\.\d{4,5})D*/, '\1')

      { "author" => get_authors(item.fetch('author', []), reversed: true, sep: ", "),
        "title" => item.fetch("title", []).first.chomp("."),
        "container-title" => "ArXiV",
        "issued" => get_date_parts(item.fetch("pubdate", nil)),
        "URL" => "http://arxiv.org/abs/#{arxiv}",
        "arxiv" => arxiv,
        "type" => "article-journal",
        "related_works" => [{ "related_work" => work.pid,
                              "source" => name,
                              "relation_type" => "cites" }] }
    end.compact
  end

  def url
    "https://api.adsabs.harvard.edu/v1/search/query?"
  end

  def events_url
    "https://ui.adsabs.harvard.edu/#search/q=body:%{query_string}"
  end
end
