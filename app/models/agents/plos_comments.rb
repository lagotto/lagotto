class PlosComments < Agent
  def get_query_url(options={})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return {} unless work.present? && work.doi =~ /^10.1371\/journal/

    url_private % { :doi => work.doi }
  end

  def parse_data(result, options={})
    return result if result[:error]

    work = Work.where(id: options.fetch(:work_id, nil)).first

    related_works = get_related_works(result, work)
    replies = get_sum(result.fetch('data', []), 'totalNumReplies')
    total = related_works.length + replies
    events_url = related_works.length > 0 ? work.canonical_url : nil

    { works: related_works,
      events: [{
        source_id: name,
        work_id: work.pid,
        discussed: total,
        total: total,
        events_url: events_url,
        extra: get_extra(result, work),
        days: get_events_by_day(related_works, work.published_on),
        months: get_events_by_month(related_works) }] }
  end

  def get_related_works(result, work)
    Array(result['data']).map do |item|
      timestamp = get_iso8601_from_time(item.fetch("created", nil))
      url = work.doi

      { "pid" => doi_as_url(work.doi),
        "author" => get_authors([item.fetch('creatorFormattedName', "")]),
        "title" => item.fetch('title', nil),
        "container-title" => 'PLOS Comments',
        "issued" => get_date_parts(timestamp),
        "timestamp" => timestamp,
        "URL" => url,
        "type" => 'personal_communication',
        "related_works" => [{ "pid" => work.pid,
                              "source_id" => name,
                              "relation_type_id" => "discusses" }] }
    end
  end

  def get_extra(result, work)
    Array(result['data']).map do |item|
      event_time = get_iso8601_from_time(item['created'])

      { event: item,
        event_time: event_time,
        event_url: nil,

        # the rest is CSL (citation style language)
        event_csl: {
          'author' => get_authors([item.fetch('creatorFormattedName', "")]),
          'title' => item.fetch('title', ""),
          'container-title' => 'PLOS Comments',
          'issued' => get_date_parts(event_time),
          'url' => work.doi_as_url(work.doi),
          'type' => 'personal_communication' }
      }
    end
  end

  def config_fields
    [:url_private]
  end
end
