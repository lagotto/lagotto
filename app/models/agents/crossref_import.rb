class CrossrefImport < Agent
  # include common methods for Import
  include Importable

  def get_query_url(options={})
    offset = options[:offset].presence || 0
    rows = options[:rows].presence || job_batch_size
    from_date = options[:from_date].presence || (Time.zone.now.to_date - 1.day).iso8601
    until_date = options[:until_date].presence || Time.zone.now.to_date.iso8601

    if only_publishers
      member = Publisher.where(service: "crossref").pluck(:member_id)
    else
      member = nil
    end

    filter = "from-update-date:#{from_date}"
    filter += ",until-update-date:#{until_date}"
    filter += member.reduce("") { |sum, m| sum + ",member:#{m}" } if member.present?

    if sample.to_i > 0
      params = { filter: filter, sample: sample }
    else
      params = { filter: filter, offset: offset, rows: rows }
    end
    url + params.to_query
  end

  def get_total(options={})
    query_url = get_query_url(options.merge(rows: 0))
    result = get_result(query_url, options)
    total = result.fetch('message', {}).fetch('total-results', 0)
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

  def get_works(result)
    # return early if an error occured
    return [] unless result.is_a?(Hash) && result.fetch('status', nil) == "ok"

    items = result.fetch('message', {}).fetch('items', nil)
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
      work_type_id = WorkType.where(name: type).pluck(:id).first

      { "author" => item.fetch("author", []),
        "container-title" => item.fetch("container-title", []).first,
        "title" => title,
        "issued" => { "date-parts" => [date_parts] },
        "DOI" => item.fetch("DOI", nil),
        "publisher_id" => publisher_id,
        "volume" => item.fetch("volume", nil),
        "issue" => item.fetch("issue", nil),
        "page" => item.fetch("page", nil),
        "type" => type,
        "tracked" => tracked }
    end
  end

  def config_fields
    [:url, :sample, :only_publishers]
  end

  def url
    "http://api.crossref.org/works?"
  end

  def sample
    config.sample
  end

  def sample=(value)
    config.sample = value.to_i
  end
end
