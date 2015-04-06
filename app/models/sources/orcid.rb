class Orcid < Source
  def response_options
    { metrics: :readers }
  end

  def get_query_string(work)
    return {} unless work.doi.present?

    work.doi_escaped
  end

  def get_related_works(result, work)
    Array(result.fetch("orcid-search-results", {}).fetch("orcid-search-result", nil)).map do |item|
      personal_details = item.fetch("orcid-profile", {}).fetch("orcid-bio", {}).fetch("personal-details", {})
      author = { "family" => personal_details.fetch("family-name", {}).fetch("value", nil),
                 "given" => personal_details.fetch("given-names", {}).fetch("value", nil) }
      url = item.fetch("orcid-profile", {}).fetch("orcid-identifier", {}).fetch("uri", nil)

      { "author" => [author],
        "title" => "ORCID profile",
        "container-title" => nil,
        "issued" => { "date-parts" => [[]] },
        "timestamp" => nil,
        "URL" => url,
        "type" => 'entry',
        "related_works" => [{ "related_work" => work.pid,
                              "source" => name,
                              "relation_type" => "bookmarks" }] }
    end
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    "http://pub.orcid.org/v1.1/search/orcid-bio/?q=digital-object-ids:\"%{query_string}\"&rows=100"
  end

  def events_url
    "https://orcid.org/orcid-search/quick-search/?searchQuery=\"%{query_string}\"&rows=100"
  end
end
