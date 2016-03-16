class Wordpress < Agent
  def get_query_string(options={})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return {} unless work.present? && (work.get_url || work.doi.present?)

    "%22" + (work.doi_escaped.presence || work.canonical_url.presence) + "%22"
  end

  def get_relations_with_related_works(result, work)
    result['data'] = nil if result['data'].is_a?(String)
    provenance_url = get_provenance_url(work_id: work.id)

    Array(result.fetch("data", nil)).map do |item|
      timestamp = get_iso8601_from_epoch(item.fetch("epoch_time", nil))
      url = item.fetch("link", nil)

      { relation: { "subj_id" => url,
                    "obj_id" => work.pid,
                    "relation_type_id" => "discusses",
                    "provenance_url" => provenance_url,
                    "source_id" => source_id },
        subj: {  "pid" => url,
                 "author" => get_authors([item.fetch('author', "")]),
                 "title" => item.fetch("title", nil),
                 "container-title" => nil,
                 "issued" => get_date_parts(timestamp),
                 "timestamp" => timestamp,
                 "URL" => url,
                 "type" => 'post',
                 "tracked" => tracked }}
    end
  end

  def config_fields
    [:url, :provenance_url]
  end

  def url
    "http://en.search.wordpress.com/?q=%{query_string}&t=post&f=json&size=20"
  end

  def provenance_url
    "http://en.search.wordpress.com/?q=%{query_string}&t=post"
  end

  def job_batch_size
    config.job_batch_size || 100
  end

  def rate_limiting
    config.rate_limiting || 1000
  end

  def queue
    config.queue || "low"
  end

  def tracked
    config.tracked || true
  end
end
