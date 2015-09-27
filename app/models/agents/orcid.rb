class Orcid < Agent
  def response_options
    { metrics: :readers }
  end

  def get_query_string(work)
    return {} unless work.doi.present?

    work.doi_escaped
  end

  def get_related_works(result, work)
    Array(result.fetch("orcid-search-results", {}).fetch("orcid-search-result", nil)).map do |item|
      item.extend Hashie::Extensions::DeepFetch
      personal_details = item.deep_fetch("orcid-profile", "orcid-bio", "personal-details") { {} }
      personal_details.extend Hashie::Extensions::DeepFetch
      author = { "family" => personal_details.deep_fetch("family-name", "value") { nil },
                 "given" => personal_details.deep_fetch("given-names", "value") { nil } }
      url = item.deep_fetch("orcid-profile", "orcid-identifier", "uri") { nil }
      timestamp = Time.zone.now.utc.iso8601

      { "author" => [author],
        "title" => "ORCID profile for #{author.fetch('given', '')} #{author.fetch('family', '')}",
        "container-title" => "ORCID Registry",
        "issued" => get_date_parts(timestamp),
        "timestamp" => timestamp,
        "URL" => url,
        "type" => 'entry',
        "tracked" => tracked,
        "registration_agency" => "orcid",
        "related_works" => [{ "related_work" => work.pid,
                              "source" => name,
                              "relation_type" => "bookmarks" }] }
    end
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    "http://pub.orcid.org/v1.2/search/orcid-bio/?q=digital-object-ids:\"%{query_string}\"&rows=100"
  end

  def events_url
    "https://orcid.org/orcid-search/quick-search/?searchQuery=\"%{query_string}\"&rows=100"
  end
end
