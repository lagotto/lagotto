class Wikipedia < Source
  # MediaWiki API Sandbox at http://en.wikipedia.org/wiki/Special:ApiSandbox
  def get_query_url(work, options={})
    return {} unless work.get_url

    host = options[:host] || "en.wikipedia.org"
    namespace = options[:namespace] || "0"
    sroffset = options[:sroffset] || 0
    continue = options[:continue] || ""
    query_string = get_query_string(work)
    url % { host: host,
            namespace: namespace,
            query_string: query_string,
            sroffset: sroffset,
            continue: continue }
  end

  def get_data(work, options={})
    if work.doi.blank?
      result = {}
    else
      # Loop through the languages, create hash with languages as keys and event arrays as values
      languages.split(" ").reduce({}) do |sum, lang|
        host = (lang == "commons") ? "commons.wikimedia.org" : "#{lang}.wikipedia.org"
        namespace = (lang == "commons") ? "6" : "0"
        query_url = get_query_url(work, host: host, namespace: namespace)
        if query_url.is_a?(Hash)
          result = {}
        else
          result = get_result(query_url, options)
        end

        if result.is_a?(Hash)
          total = result.fetch("query", {}).fetch("searchinfo", {}).fetch("totalhits", nil).to_i
          sum[lang] = parse_related_works(result, host)

          if total > rows
            # walk through paginated results
            total_pages = (total.to_f / rows).ceil

            (1...total_pages).each do |page|
              options[:sroffset] = page * 50
              options[:continue] = result.fetch("continue", {}).fetch("continue", "")
              query_url = get_query_url(work, options)
              paged_result = get_result(query_url, options)
              sum[lang] = sum[lang] | parse_related_works(paged_result, host)
            end
          end
        else
          sum[lang] = []
        end
        sum
      end
    end
  end

  def parse_related_works(result, host)
    result.fetch("query", {}).fetch("search", []).map do |event|
      { "title" => event.fetch("title", nil),
        "url" => "http://#{host}/wiki/#{event.fetch("title", nil).gsub(" ", "_")}",
        "timestamp" => event.fetch("timestamp", nil) }
    end
  end

  def parse_data(result, work, options={})
    return result if result[:error]

    related_works = get_related_works(result, work)
    total = related_works.length
    events_url = total > 0 ? get_events_url(work) : nil

    { works: related_works,
      metrics: {
        source: name,
        work: work.pid,
        total: total,
        events_url: events_url,
        days: get_events_by_day(related_works, work, options),
        months: get_events_by_month(related_works, options) } }
  end

  def get_related_works(result, work)
    result.values.flatten.map do |item|
      timestamp = item.fetch("timestamp", nil)
      url = item.fetch("url", nil)

      { "author" => nil,
        "title" => item.fetch("title", ""),
        "container-title" => "Wikipedia",
        "issued" => get_date_parts(timestamp),
        "timestamp" => timestamp,
        "URL" => url,
        "type" => "entry-encyclopedia",
        "related_works" => [{ "related_work" => work.pid,
                              "source" => name,
                              "relation_type" => "references" }] }
    end
  end

  def config_fields
    [:url, :events_url, :languages]
  end

  def url
    "http://%{host}/w/api.php?action=query&list=search&format=json&srsearch=%{query_string}&srnamespace=%{namespace}&srwhat=text&srinfo=totalhits&srprop=timestamp&srlimit=50&sroffset=%{sroffset}&continue=%{continue}"
  end

  def events_url
    "http://en.wikipedia.org/w/index.php?search=%{query_string}"
  end

  def job_batch_size
    config.job_batch_size || 50
  end

  def rows
    50
  end
end
