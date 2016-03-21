class CrossrefPublisher < Agent
  # include common methods for Import
  include Importable

  def get_query_url(options={})
    offset = options[:offset].to_i
    rows = options[:rows].presence || job_batch_size

    params = { offset: offset, rows: rows }

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
      total_pages = (total.to_f / job_batch_size).ceil

      (0...total_pages).each do |page|
        options[:offset] = page * job_batch_size
        AgentJob.set(queue: queue, wait_until: schedule_at).perform_later(self, options)
      end
    end

    # return number of works queued
    total
  end

  def parse_data(result, options={})
    result = { error: "No hash returned." } unless result.is_a?(Hash)
    return result if result[:error]

    items = result.fetch('message', {}).fetch('items', nil)

    Array(items).map do |item|
      publisher_name = item.fetch('id', nil).to_s
      title = item.fetch('primary-name', nil) || item.fetch('names', []).first

      { message_type: "publisher",
        relation: { "subj_id" => publisher_name,
                    "source_id" => name },
        subj: { "name" => publisher_name,
                "title" => title,
                "other_names" => item.fetch('names', []),
                "prefixes" => item.fetch('prefixes', []),
                "registration_agency" => "crossref",
                "active" => true } }
    end
  end

  def config_fields
    [:url]
  end

  def url
    "http://api.crossref.org/members?"
  end

  def cron_line
    config.cron_line || "40 2 * * 1"
  end

  def job_batch_size
    config.job_batch_size || 1000
  end
end
