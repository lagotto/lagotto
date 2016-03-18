class Reddit < Agent
  def parse_data(result, options={})
    return [result] if result[:error]
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return [{ error: "Resource not found.", status: 404 }] unless work.present?

    result = result.deep_fetch('data', 'children') { [] }

    likes = get_sum(result, 'data', 'score')
    comments = get_sum(result, 'data', 'num_comments')
    total = likes + comments
    related_works = get_related_works(result, work)
    extra = get_extra(result)
    provenance_url = total > 0 ? get_provenance_url(work_id: work.id) : nil

    { works: related_works,
      events: [{
        source_id: name,
        work_id: work.pid,
        comments: comments,
        likes: likes,
        total: total,
        events_url: events_url,
        extra: extra,
        months: get_events_by_month(related_works) }] }
  end

  def get_related_works(result, work)
    result.map do |item|
      data = item.fetch('data', {})
      timestamp = get_iso8601_from_epoch(data.fetch('created_utc', nil))
      url = data.fetch('url', nil)

      { "pid" => url,
        "author" => get_authors([data.fetch('author', "")]),
        "title" => data.fetch("title", ""),
        "container-title" => "Reddit",
        "issued" => get_date_parts(timestamp),
        "timestamp" => timestamp,
        "URL" => url,
        "type" => "personal_communication",
        "tracked" => tracked,
        "registration_agency" => "reddit",
        "related_works" => [{ "pid" => work.pid,
                              "source_id" => name,
                              "relation_type_id" => "discusses" }] }
    end
  end

  def get_extra(result)
    result.map do |item|
      data = item['data']
      event_time = get_iso8601_from_epoch(data['created_utc'])
      url = data['url']

      { event: data,
        event_time: event_time,
        event_url: url,

        # the rest is CSL (citation style language)
        event_csl: {
          'author' => get_authors([data.fetch('author', "")]),
          'title' => data.fetch('title', ""),
          'container-title' => 'Reddit',
          'issued' => get_date_parts(event_time),
          'url' => url,
          'type' => 'personal_communication' }
      }
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
