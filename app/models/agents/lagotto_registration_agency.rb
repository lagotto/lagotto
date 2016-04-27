class LagottoRegistrationAgency < Agent
  def get_query_url(options={})
    offset = (options[:offset] || 1).to_i
    rows = options[:rows].presence || job_batch_size
    from_date = options[:from_date].presence || (Time.zone.now.to_date - 1.day).iso8601
    until_date = options[:until_date].presence || Time.zone.now.to_date.iso8601

    params = { registration_agency_id: registration_agency_id,
               from_date: from_date,
               until_date: until_date,
               page: offset,
               per_page: rows }
    url_private +  URI.encode_www_form(params)
  end

  def get_total(options={})
    query_url = get_query_url(options.merge(rows: 0))
    result = get_result(query_url, options)
    result.fetch("meta", {}).fetch("total", 0)
  end

  def queue_jobs(options={})
    return 0 unless active?

    unless options[:all]
      return 0 unless stale?
    end

    total = get_total(options)

    if total > 0
      # walk through paginated results
      total_pages = (total.to_f / job_batch_size).ceil

      (1...total_pages).each do |page|
        options[:offset] = page
        AgentJob.set(queue: queue, wait_until: schedule_at).perform_later(self, options)
      end

      schedule_next_run
    end

    # return number of works queued
    total
  end

  def get_data(options={})
    query_url = get_query_url(options)
    get_result(query_url, options)
  end

  def parse_data(result, options={})
    result = { error: "No hash returned." } unless result.is_a?(Hash)
    return [result] if result[:error]

    result.fetch('deposits', [])
  end

  def config_fields
    [:url_private, :registration_agency_id]
  end

  def registration_agency_id
    config.registration_agency_id
  end

  def registration_agency_id=(value)
    config.registration_agency_id = value
  end

  def cron_line
    config.cron_line || "40 22 * * *"
  end

  def timeout
    config.timeout || 120
  end

  def job_batch_size
    config.job_batch_size || 1000
  end

  def tracked
    config.tracked || true
  end
end
