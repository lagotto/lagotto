class PlosImport < Agent
  def get_query_url(options={})
    offset = options[:offset].presence || 0
    rows = options[:rows].presence || job_batch_size
    from_pub_date = options[:from_pub_date].presence || (Time.zone.now.to_date - 1.day).iso8601
    until_pub_date = options[:until_pub_date].presence || Time.zone.now.to_date.iso8601

    date_range = "publication_date:[#{from_pub_date}T00:00:00Z TO #{until_pub_date}T23:59:59Z]"
    params = { q: "*:*",
               start: offset,
               rows: rows,
               fl: "id,publication_date,title_display,cross_published_journal_name,author_display,volume,issue,elocation_id",
               fq: "+#{date_range}+doc_type:full",
               wt: "json" }
    url + params.to_query
  end

  def get_total(options={})
    query_url = get_query_url(options.merge(rows: 0))
    result = get_result(query_url, options)
    total = result.fetch("response", {}).fetch("numFound", 0)
  end

  def queue_jobs(options={})
    return 0 unless active?

    query_url = get_query_url(options.merge(rows: 0))
    result = get_result(query_url, options)
    total = result.fetch("response", {}).fetch("numFound", 0)

    if total > 0
      # walk through paginated results
      total = sample if sample.present?
      total_pages = (total.to_f / job_batch_size).ceil

      (0...total_pages).each do |page|
        options[:offset] = page * job_batch_size
        options[:rows] = sample if sample && sample < (page + 1) * job_batch_size
        AgentJob.set(queue: queue, wait_until: schedule_at).perform_later(nil, self, options)
      end
    end

    # return number of works queued
    total
  end

  def get_data(_work, options={})
    query_url = get_query_url(options)
    result = get_result(query_url, options)
  end

  def parse_data(result, _work, options={})
    return result if result[:error]

    { works: get_works(result) }
  end

  def get_works(result)
    # return early if an error occured
    return [] unless result.is_a?(Hash) && result.fetch("response", nil)

    items = result.fetch('response', {}).fetch('docs', nil)
    Array(items).map do |item|
      timestamp = get_iso8601_from_time(item.fetch("publication_date", nil))
      date_parts = get_date_parts(timestamp)

      { "author" => get_authors(item.fetch("author_display", [])),
        "container-title" => item.fetch("cross_published_journal_name", []).first,
        "title" => item.fetch("title_display", nil),
        "issued" => date_parts,
        "DOI" => item.fetch("id", nil),
        "publisher_id" => publisher_id,
        "volume" => item.fetch("volume", nil),
        "issue" => item.fetch("issue", nil),
        "page" => item.fetch("elocation_id", nil),
        "type" => "article-journal" }
    end
  end

  def config_fields
    [:url, :sample]
  end

  def url
    "http://api.plos.org/search?"
  end

  # publisher_id is PLOS CrossRef member id
  def publisher_id
    340
  end

  def cron_line
    config.cron_line || "20 11,16 * * 1-5"
  end

  def queue
    config.queue || "high"
  end

  def job_batch_size
    config.job_batch_size || 1000
  end
end
