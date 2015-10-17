class CrossrefOrcid < Agent
  # include common methods for Import
  include Importable

  def get_query_url(options={})
    offset = options[:offset].to_i
    rows = options[:rows].presence || job_batch_size
    from_date = options[:from_date].presence || (Time.zone.now.to_date - 1.day).iso8601
    until_date = options[:until_date].presence || Time.zone.now.to_date.iso8601

    filter = "has-orcid:true"
    filter += ",from-update-date:#{from_date}"
    filter += ",until-update-date:#{until_date}"

    params = { filter: filter, offset: offset, rows: rows }

    url + params.to_query
  end

  def get_total(options={})
    query_url = get_query_url(options.merge(rows: 0))
    result = get_result(query_url, options)
    result.fetch('message', {}).fetch('total-results', 0)
  end

  def queue_jobs(options={})
    return 0 unless active?

    query_url = get_query_url(options.merge(rows: 0))
    result = get_result(query_url, options)
    total = result.fetch("message", {}).fetch("total-results", 0)

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

  def parse_data(result, options={})
    result = { error: "No hash returned." } unless result.is_a?(Hash)
    return result if result[:error]

    items = result.fetch('message', {}).fetch('items', nil)

    { works: get_works(items),
      events: get_events(items) }
  end

  def get_works(items)
    Array(items).map do |item|
      date_parts = item.fetch("issued", {}).fetch("date-parts", []).first
      year, month, day = date_parts[0], date_parts[1], date_parts[2]

      # use date indexed if date issued is in the future
      if year.nil? || Date.new(*date_parts) > Time.zone.now.to_date
        date_parts = item.fetch("indexed", {}).fetch("date-parts", []).first
        year, month, day = date_parts[0], date_parts[1], date_parts[2]
      end

      title = case item["title"].length
              when 0 then nil
              when 1 then item["title"][0]
              else item["title"][0].presence || item["title"][1]
              end

      if title.blank? && !TYPES_WITH_TITLE.include?(item["type"])
        title = item["container-title"][0].presence || "No title"
      end
      publisher_id = item.fetch("member", nil)
      publisher_id = publisher_id[30..-1].to_i if publisher_id

      type = item.fetch("type", nil)
      type = CROSSREF_TYPE_TRANSLATIONS[type] if type
      doi = item.fetch("DOI", nil)

      authors_with_orcid = item.fetch('author', []).select { |author| author["ORCID"].present? }
      related_works = authors_with_orcid.map { |work| get_related_work(work) }

      { "pid" => doi_as_url(doi),
        "author" => item.fetch("author", []),
        "container-title" => item.fetch("container-title", []).first,
        "title" => title,
        "issued" => { "date-parts" => [date_parts] },
        "DOI" => doi,
        "publisher_id" => publisher_id,
        "volume" => item.fetch("volume", nil),
        "issue" => item.fetch("issue", nil),
        "page" => item.fetch("page", nil),
        "type" => type,
        "tracked" => tracked,
        "related_works" => related_works }
    end
  end

  def get_related_work(work)
    { "pid" => work['ORCID'],
      "source_id" => name,
      "relation_type_id" => "is_bookmarked_by" }
  end

  def get_events(items)
    Array(items).map do |item|
      pid = doi_as_url(item.fetch("DOI"))
      authors_with_orcid = item.fetch('author', []).select { |author| author["ORCID"].present? }

      { source_id: name,
        work_id: pid,
        total: authors_with_orcid.length }
    end
  end

  def config_fields
    [:url]
  end

  def url
    "http://api.crossref.org/works?"
  end
end
