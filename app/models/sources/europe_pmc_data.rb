class EuropePmcData < Source
  def get_query_url(work)
    if url.starts_with?("http://www.ebi.ac.uk/europepmc/webservices/rest/MED/")
      return nil unless url.present? && work.get_ids && work.pmid.present?

      url % { :pmid => work.pmid }
    elsif url.starts_with?("http://www.ebi.ac.uk/europepmc/webservices/rest/search/query")
      return nil unless work.doi.present?

      url % { :doi => work.doi }
    end
  end

  def parse_data(result, work, options={})
    return result if result[:error]
    result = result.fetch("responseWrapper", nil) || result

    total = result.fetch("hitCount", nil).to_i
    events = get_events(result)
    events_url = total > 0 ? get_events_url(work) : nil

    { events: events,
      events_by_day: [],
      events_by_month: [],
      events_url: events_url,
      total: total,
      event_metrics: get_event_metrics(citations: total),
      extra: nil }
  end

  def get_events(result)
    if result.fetch("dbCountList", nil)
      result["dbCountList"]["db"].reduce({}) { |hash, db| hash.update(db["dbName"] => db["count"]) }
    elsif result.fetch("resultList", nil)
      result.extend Hashie::Extensions::DeepFetch
      events = result.deep_fetch('resultList', 'result') { nil }
      events = [events] if events.is_a?(Hash)
      Array(events).map do |item|
        url = item['pmid'].nil? ? nil : "http://europepmc.org/abstract/MED/#{item['pmid']}"

        { "author" => get_authors([item.fetch('authorString', "")]),
          "title" => item.fetch('title', nil),
          "container-title" => item.fetch('journalTitle', nil),
          "issued" => get_date_parts_from_parts((item.fetch("pubYear", nil)).to_i),
          "URL" => url,
          "type" => 'article-journal' }
      end
    else
      []
    end
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
