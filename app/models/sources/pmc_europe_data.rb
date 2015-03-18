# encoding: UTF-8

class PmcEuropeData < Source
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
    result = result["responseWrapper"] || result

    event_count = (result["hitCount"]).to_i
    events = get_events(result)
    events_url = event_count > 0 ? get_events_url(work) : nil

    { events: events,
      events_by_day: [],
      events_by_month: [],
      events_url: events_url,
      event_count: event_count,
      event_metrics: get_event_metrics(citations: event_count) }
  end

  def get_events(result)
    if result["dbCountList"]
      result["dbCountList"]["db"].reduce({}) { |hash, db| hash.update(db["dbName"] => db["count"]) }
    elsif result["resultList"]
      result.extend Hashie::Extensions::DeepFetch
      events = result.deep_fetch('resultList', 'result') { nil }
      events = [events] if events.is_a?(Hash)
      Array(events).map do |item|
        url = item['pmid'] ? "http://europepmc.org/abstract/MED/#{item['pmid']}" : nil
        { event: item,
          event_url: url,

          # the rest is CSL (citation style language)
          event_csl: {
            'author' => get_authors([item.fetch('authorString', "")]),
            'title' => item.fetch('title', ""),
            'container-title' => item.fetch('journalTitle', ""),
            'issued' => get_date_parts_from_parts((item['pubYear']).to_i),
            'url' => url,
            'type' => 'article-journal' }
        }
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
