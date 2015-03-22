class Datacite < Source
  def get_query_url(work)
    if url.present? && work.doi.present?
      url % { doi: work.doi_escaped }
    end
  end

  def get_events_url(work)
    if events_url.present? && work.doi.present?
      events_url % { doi: work.doi_escaped }
    end
  end

  def get_events(result)
    result["response"] ||= {}
    Array(result["response"]["docs"]).map { |item| { event: item, event_url: "http://doi.org/#{item['doi']}" } }
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    "http://search.datacite.org/api?q=relatedIdentifier:%{doi}&fl=relatedIdentifier,doi,creator,title,publisher,publicationYear&fq=is_active:true&fq=has_metadata:true&indent=true&rows=100&wt=json"
  end

  def events_url
    "http://search.datacite.org/ui?q=relatedIdentifier:%{doi}"
  end
end
