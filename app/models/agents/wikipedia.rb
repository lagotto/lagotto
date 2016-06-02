class Wikipedia < Agent
  # MediaWiki API Sandbox at http://en.wikipedia.org/wiki/Special:ApiSandbox
  def get_query_url(options={})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return {} unless work.present? && work.get_url

    host = options[:host] || "en.wikipedia.org"
    namespace = options[:namespace] || "0"
    sroffset = options[:sroffset] || 0
    continue = options[:continue] || ""
    query_string = get_query_string(options)
    url % { host: host,
            namespace: namespace,
            query_string: query_string,
            sroffset: sroffset,
            continue: continue }
  end

  def get_data(options={})
    work_id = options.fetch(:work_id, nil)

    if work_id.nil?
      result = {}
    else
      # Loop through the languages, create hash with languages as keys and event arrays as values
      languages.split(" ").reduce({}) do |sum, lang|
        host = (lang == "commons") ? "commons.wikimedia.org" : "#{lang}.wikipedia.org"
        namespace = (lang == "commons") ? "6" : "0"
        query_url = get_query_url(work_id: work_id, host: host, namespace: namespace)
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
              query_url = get_query_url(options)
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

  def get_relations_with_related_works(result, work)
    provenance_url = get_provenance_url(work_id: work.id)

    result.values.flatten.map do |item|
      url = item.fetch("url", nil)

      { prefix: work.prefix,
        relation: { "subj_id" => url,
                    "obj_id" => work.pid,
                    "relation_type_id" => "references",
                    "provenance_url" => provenance_url,
                    "source_id" => source_id },
        subj: { "pid" => url,
                "author" => nil,
                "title" => item.fetch("title", ""),
                "container-title" => "Wikipedia",
                "issued" => item.fetch("timestamp", nil),
                "URL" => url,
                "type" => "entry-encyclopedia",
                "tracked" => tracked,
                "registration_agency_id" => "wikipedia" }}
    end
  end

  def config_fields
    [:url, :provenance_url, :languages]
  end

  def url
    "http://%{host}/w/api.php?action=query&list=search&format=json&srsearch=%{query_string}&srnamespace=%{namespace}&srwhat=text&srinfo=totalhits&srprop=timestamp&srlimit=50&sroffset=%{sroffset}&continue=%{continue}"
  end

  def provenance_url
    "http://en.wikipedia.org/w/index.php?search=%{query_string}"
  end

  def job_batch_size
    config.job_batch_size || 50
  end

  def rows
    50
  end
end
