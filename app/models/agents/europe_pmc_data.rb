class EuropePmcData < Agent
  def get_query_url(options={})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return {} unless work.present? && work.get_ids && work.pmid.present?

    url % { :pmid => work.pmid }
  end

  def get_provenance_url(options={})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return nil unless work.present? && work.pmid.present?

    provenance_url % { :pmid => work.pmid }
  end

  def parse_data(result, options={})
    return [result] if result[:error]
    result = result.fetch("responseWrapper", nil) || result

    work = Work.where(id: options.fetch(:work_id, nil)).first
    return [{ error: "Resource not found.", status: 404 }] unless work.present?

    relations = []

    total = result.fetch("hitCount", nil).to_i

    if total > 0
      relations << { prefix: work.prefix,
                     relation: { "subj_id" => "https://europepmc.org",
                                 "obj_id" => work.pid,
                                 "relation_type_id" => "cites",
                                 "total" => total,
                                 "provenance_url" => get_provenance_url(work_id: work.id),
                                 "source_id" => source_id },
                     subj: { "pid"=>"https://europepmc.org",
                             "URL"=>"https://europepmc.org",
                             "title"=>"Europe PMC",
                             "type"=>"webpage",
                             "issued"=>"2012-05-15T16:40:23Z" }}
    end

    relations
  end

  def config_fields
    [:url, :provenance_url]
  end

  def url
    "http://www.ebi.ac.uk/europepmc/webservices/rest/MED/%{pmid}/databaseLinks//1/json"
  end

  def provenance_url
    "http://europepmc.org/abstract/MED/%{pmid}#fragment-related-bioentities"
  end
end
