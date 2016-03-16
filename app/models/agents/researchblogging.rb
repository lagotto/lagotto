class Researchblogging < Agent
  def request_options
    { content_type: 'xml', username: username, password: password }
  end

  def get_query_string(options={})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return {} unless work.present? && work.doi.present?

    work.doi_escaped
  end

  def get_relations_with_related_works(result, work)
    related_works = result.deep_fetch('blogposts', 'post') { nil }
    related_works = [related_works] if related_works.is_a?(Hash)
    provenance_url = get_provenance_url(work_id: work.id)

    Array(related_works).map do |item|
      url = item.fetch("post_URL", nil)

      { relation: { "subj_id" => url,
                    "obj_id" => work.pid,
                    "relation_type_id" => "discusses",
                    "provenance_url" => provenance_url,
                    "source_id" => source_id },
        subj: { "pid" => url,
                "author" => get_authors([item.fetch('blogger_name', nil)]),
                "title" => item.fetch('post_title', "No title"),
                "container-title" => item.fetch('blog_name', nil),
                "issued" => get_iso8601_from_time(item.fetch("published_date", nil)),
                "URL" => url,
                "type" => 'post',
                "tracked" => tracked }}
    end
  end

  def config_fields
    [:url, :provenance_url, :username, :password]
  end

  def url
    "http://researchbloggingconnect.com/blogposts?count=100&article=doi:%{query_string}"
  end

  def provenance_url
    "http://researchblogging.org/post-search/list?article=%{query_string}"
  end

  def cron_line
    config.cron_line || "* 7 28 * *"
  end

  def rate_limiting
    config.rate_limiting || 2000
  end

  def job_batch_size
    config.job_batch_size || 50
  end

  def tracked
    config.tracked || true
  end
end
