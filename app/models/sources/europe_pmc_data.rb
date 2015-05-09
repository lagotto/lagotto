class EuropePmcData < Source
  def get_query_url(work)
    if url.starts_with?("http://www.ebi.ac.uk/europepmc/webservices/rest/MED/")
      return {} unless work.get_ids && work.pmid.present?

      url % { :pmid => work.pmid }
    elsif url.starts_with?("http://www.ebi.ac.uk/europepmc/webservices/rest/search/query")
      return {} unless work.doi.present?

      url % { :doi => work.doi }
    end
  end

  def parse_data(result, work, options={})
    return result if result[:error]
    result = result.fetch("responseWrapper", nil) || result

    total = result.fetch("hitCount", nil).to_i
    related_works = get_related_works(result, work)
    events_url = total > 0 ? get_events_url(work) : nil

    { works: related_works,
      events: {
        source: name,
        work: work.pid,
        total: total,
        events_url: events_url,
        extra: get_extra(result) } }
  end

  def get_related_works(result, work)
    result.extend Hashie::Extensions::DeepFetch
    related_works = result.deep_fetch('resultList', 'result') { nil }
    related_works = [related_works] if related_works.is_a?(Hash)
    Array(related_works).map do |item|
      url = item['pmid'].nil? ? nil : "http://europepmc.org/abstract/MED/#{item['pmid']}"

      { "author" => get_authors([item.fetch('authorString', "")]),
        "title" => item.fetch('title', nil),
        "container-title" => item.fetch('journalTitle', nil),
        "issued" => get_date_parts_from_parts((item.fetch("pubYear", nil)).to_i),
        "URL" => url,
        "type" => 'article-journal',
        "related_works" => [{ "related_work" => work.pid,
                              "source" => name,
                              "relation_type" => "cites" }] }
    end
  end

  def get_extra(result)
    result = result.deep_fetch('dbCountList', 'db') { [] }
    result.reduce({}) { |hash, db| hash.update(db["dbName"] => db["count"]) }
  end

  def get_events_url(work)
    if work.pmid.present?
      events_url % { :pmid => work.pmid }
    else
      nil
    end
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    "http://www.ebi.ac.uk/europepmc/webservices/rest/MED/%{pmid}/databaseLinks//1/json"
  end

  def events_url
    "http://europepmc.org/abstract/MED/%{pmid}#fragment-related-bioentities"
  end
end
