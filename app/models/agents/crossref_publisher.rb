class CrossrefPublisher < Agent
  # include common methods for Crossref
  include Crossrefable

  def get_query_url(options={})
    offset = options[:offset].to_i
    rows = options[:rows].presence || job_batch_size

    params = { offset: offset, rows: rows }

    url + params.to_query
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
                "issued" => get_iso8601_from_epoch(item.fetch('last-status-check-time', nil)),
                "registration_agency_id" => "crossref",
                "active" => true } }
    end
  end

  def url
    "http://api.crossref.org/members?"
  end

  def cron_line
    config.cron_line || "40 2 * * 1"
  end
end
