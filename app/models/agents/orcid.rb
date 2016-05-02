class Orcid < Agent
  def get_query_string(options={})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return {} unless work.present? && work.doi.present?

    work.doi_escaped
  end

  def get_relations_with_related_works(result, work)
    Array(result.fetch("orcid-search-results", {}).fetch("orcid-search-result", nil)).map do |item|
      item.extend Hashie::Extensions::DeepFetch
      personal_details = item.deep_fetch("orcid-profile", "orcid-bio", "personal-details") { {} }
      personal_details.extend Hashie::Extensions::DeepFetch
      author = { "family" => personal_details.deep_fetch("family-name", "value") { nil },
                 "given" => personal_details.deep_fetch("given-names", "value") { nil } }
      url = item.deep_fetch("orcid-profile", "orcid-identifier", "uri") { nil }
      timestamp = Time.zone.now.utc.iso8601

      { prefix: work.prefix,
        contribution: { "subj_id" => url,
                        "obj_id" => work.pid,
                        "source_id" => source_id },
        subj: { "pid" => url,
                "author" => [author],
                "title" => "ORCID profile for #{author.fetch('given', '')} #{author.fetch('family', '')}",
                "container-title" => "ORCID Registry",
                "issued" => Time.zone.now.utc.iso8601,
                "URL" => url,
                "type" => 'entry',
                "tracked" => tracked,
                "registration_agency_id" => "orcid" }}
    end
  end

  def config_fields
    [:url]
  end

  def url
    "http://pub.orcid.org/v1.2/search/orcid-bio/?q=digital-object-ids:\"%{query_string}\"&rows=100"
  end
end
