class Reddit < Agent
  def parse_data(result, options={})
    return [result] if result[:error]
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return [{ error: "Resource not found.", status: 404 }] unless work.present?

    result = result.deep_fetch('data', 'children') { [] }

    likes = get_sum(result, 'data', 'score')

    relations = get_relations_with_related_works(result, work)

    if likes > 0
      relations << { prefix: work.prefix,
                     relation: { "subj_id" => "https://www.reddit.com",
                                 "obj_id" => work.pid,
                                 "relation_type_id" => "likes",
                                 "total" => likes,
                                 "provenance_url" => get_provenance_url(work_id: work.id),
                                 "source_id" => source_id },
                     subj: { "pid" => "https://www.reddit.com",
                             "URL" => "https://www.reddit.com",
                             "title" => "Reddit",
                             "type" => "webpage",
                             "issued" => "2012-05-15T16:40:23Z" }}
    end

    relations
  end

  def get_relations_with_related_works(result, work)
    result.map do |item|
      data = item.fetch('data', {})
      url = data.fetch('url', nil)
      provenance_url = get_provenance_url(work_id: work.id)

      { relation: { "subj_id" => url,
                    "obj_id" => work.pid,
                    "relation_type_id" => "discusses",
                    "provenance_url" => provenance_url,
                    "source_id" => source_id },
        subj: { "pid" => url,
                "author" => get_authors([data.fetch('author', "")]),
                "title" => data.fetch("title", ""),
                "container-title" => "Reddit",
                "issued" => get_iso8601_from_epoch(data.fetch('created_utc', nil)),
                "URL" => url,
                "type" => "personal_communication",
                "tracked" => tracked,
                "registration_agency_id" => "reddit" }}
    end
  end

  def config_fields
    [:url, :provenance_url]
  end

  def url
    "http://www.reddit.com/search.json?q=%{query_string}&limit=100"
  end

  def provenance_url
    "http://www.reddit.com/search?q=%{query_string}"
  end

  def job_batch_size
    config.job_batch_size || 100
  end

  def rate_limiting
    config.rate_limiting || 1800
  end

  def queue
    config.queue || "low"
  end
end
