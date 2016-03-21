class PlosComments < Agent
  def get_query_url(options={})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return {} unless work.present? && work.doi =~ /^10.1371\/journal/ && work.get_url

    url_private % { :doi => work.doi }
  end

  def get_provenance_url(options={})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return nil unless work.present? && work.canonical_url.present?

    work.canonical_url.sub("article?id=", "article/comments?id=")
  end

  def parse_data(result, options={})
    return [result] if result[:error]

    work = Work.where(id: options.fetch(:work_id, nil)).first
    return [{ error: "Resource not found.", status: 404 }] unless work.present?

    get_relations_with_related_works(result, work)
  end

  def get_relations_with_related_works(result, work)
    provenance_url = get_provenance_url(work_id: work.id)
    base_url = provenance_url[0...provenance_url.index("comments")]

    Array(result['data']).map do |item|
      annotation_url = item.fetch("annotationUri", nil)
      url = base_url + "comment?id=" + CGI.escape("info:doi/" + annotation_url)

      { prefix: work.prefix,
        relation: { "subj_id" => url,
                    "obj_id" => work.pid,
                    "relation_type_id" => "discusses",
                    "provenance_url" => provenance_url,
                    "source_id" => source_id },
        subj: { "pid" => url,
                "author" => get_authors([item.fetch('creatorFormattedName', "")]),
                "title" => item.fetch('title', nil),
                "container-title" => 'PLOS Comments',
                "issued" => get_iso8601_from_time(item.fetch("created", nil)),
                "URL" => url,
                "type" => 'personal_communication',
                "tracked" => tracked }}
    end
  end

  def config_fields
    [:url_private]
  end
end
