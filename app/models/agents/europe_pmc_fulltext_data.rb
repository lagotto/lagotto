class EuropePmcFulltextData < Agent
  def get_query_url(options={})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return {} unless work.present? &&  work.doi.present?

    url % { :doi => work.doi }
  end

  def parse_data(result, options={})
    return [result] if result[:error]
    result = result.fetch("responseWrapper", nil) || result

    work = Work.where(id: options.fetch(:work_id, nil)).first
    return [{ error: "Resource not found.", status: 404 }] unless work.present?

    get_relations_with_related_works(result, work)
  end

  def get_relations_with_related_works(result, work)
    result.extend Hashie::Extensions::DeepFetch
    related_works = result.deep_fetch('resultList', 'result') { nil }
    related_works = [related_works] if related_works.is_a?(Hash)
    provenance_url = get_provenance_url(work_id: work.id)

    Array(related_works).map do |item|
      url = item['pmid'].nil? ? nil : "http://europepmc.org/abstract/MED/#{item['pmid']}"

      { relation: { "subj_id" => url,
                    "obj_id" => work.pid,
                    "relation_type_id" => "cites",
                    "provenance_url" => provenance_url,
                    "source_id" => source_id },
        subj: { "pid" => url,
                "author" => get_authors([item.fetch('authorString', "")]),
                "title" => item.fetch('title', nil),
                "container-title" => item.fetch('journalTitle', nil),
                "issued" => item.fetch("pubYear", nil),
                "URL" => url,
                "type" => 'article-journal',
                "tracked" => tracked }}
    end
  end

  def get_provenance_url(options={})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return nil unless work.present? && work.pmid.present?

    provenance_url % { :pmid => work.pmid }
  end

  def config_fields
    [:url, :provenance_url]
  end

  def url
    "http://www.ebi.ac.uk/europepmc/webservices/rest/search/query=ACCESSION_ID:%{doi}"
  end

  def provenance_url
    "http://europepmc.org/abstract/MED/%{pmid}#fragment-related-bioentities"
  end
end
