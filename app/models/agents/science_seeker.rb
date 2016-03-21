class ScienceSeeker < Agent
  def request_options
    { content_type: 'xml' }
  end

  def get_query_string(options={})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return {} unless work.present? && work.doi.present?

    work.doi_escaped
  end

  def get_relations_with_related_works(result, work)
    related_works = result.fetch('feed', nil) && result.deep_fetch('feed', 'entry') { nil }
    related_works = [related_works] if related_works.is_a?(Hash)
    provenance_url = get_provenance_url(work_id: work.id)

    Array(related_works).map do |item|
      item.extend Hashie::Extensions::DeepFetch
      url = item.fetch("link", {}).fetch("href", nil)

      { prefix: work.prefix,
        relation: { "subj_id" => url,
                    "obj_id" => work.pid,
                    "relation_type_id" => "discusses",
                    "provenance_url" => provenance_url,
                    "source_id" => source_id },
        subj: { "pid" => url,
                "author" => get_authors([item.fetch('author', {}).fetch('name', "")]),
                "title" => item.fetch('title', nil),
                "container-title" => item.fetch('source', {}).fetch('title', ""),
                "issued" => get_iso8601_from_time(item.fetch("updated", nil)),
                "URL" => url,
                "type" => 'post',
                "tracked" => tracked }}
    end
  end

  def config_fields
    [:url, :provenance_url]
  end

  def url
    "http://scienceseeker.org/search/default/?type=post&filter0=citation&modifier0=doi&value0=%{query_string}"
  end

  def provenance_url
    "http://scienceseeker.org/posts/?filter0=citation&modifier0=doi&value0=%{query_string}"
  end

  def cron_line
    config.cron_line || "* 7 28 * *"
  end

  def rate_limiting
    config.rate_limiting || 1000
  end

  def tracked
    config.tracked || true
  end
end
