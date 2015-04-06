class PlosComments < Source
  def get_query_url(work)
    return {} unless work.doi =~ /^10.1371\/journal/

    url_private % { :doi => work.doi }
  end

  def parse_data(result, work, options={})
    return result if result[:error]

    related_works = get_related_works(result, work)
    replies = get_sum(result.fetch('data', []), 'totalNumReplies')
    total = related_works.length + replies
    events_url = related_works.length > 0 ? work.canonical_url : nil

    { works: related_works,
      metrics: {
        source: name,
        work: work.pid,
        discussed: total,
        total: total,
        events_url: events_url,
        days: get_events_by_day(related_works, work),
        months: get_events_by_month(related_works) } }
  end

  def get_related_works(result, work)
    Array(result['data']).map do |item|
      timestamp = get_iso8601_from_time(item.fetch("created", nil))

      { "author" => get_authors([item.fetch('creatorFormattedName', "")]),
        "title" => item.fetch('title', nil),
        "container-title" => 'PLOS Comments',
        "issued" => get_date_parts(timestamp),
        "timestamp" => timestamp,
        "URL" => work.doi_as_url,
        "type" => 'personal_communication',
        "related_works" => [{ "related_work" => work.pid,
                              "source" => name,
                              "relation_type" => "discusses" }] }
    end
  end

  def config_fields
    [:url_private]
  end
end
