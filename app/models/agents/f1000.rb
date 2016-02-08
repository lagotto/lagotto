class F1000 < Agent
  def get_query_url(options={})
    fail ArgumentError, "Agent url is missing." if url_private.blank?

    url_private
  end

  def queue_jobs(options={})
    return 0 unless active?

    query_url = get_query_url(options)
    result = get_result(query_url, options)
    total = result.fetch("ObjectList", []).fetch("Article", []).length

    if total > 0
      # walk through paginated results
      total_pages = (total.to_f / job_batch_size).ceil

      (0...total_pages).each do |page|
        AgentJob.set(queue: queue, wait_until: schedule_at).perform_later(self, options)
      end
    end

    # return number of works queued
    total
  end

  def get_data(options={})
    query_url = get_query_url(options)
    result = get_result(query_url, options)
  end

  def parse_data(result, options={})
    # properly handle not found errors
    result = { "ObjectList" => { "Article" => [] }} if result[:status] == 404

    return result if result[:error]

    { events: get_events(result) }
  end

  def get_events(result)
    recommendations = result.fetch("ObjectList", {}).fetch("Article", [])

    Array(recommendations).map do |item|
      doi = item.fetch('Doi', nil)
      # sometimes doi metadata are missing
      break unless doi

      # turn classifications into array with lowercase letters
      classifications = item['Classifications'] ? item['Classifications'].downcase.split(", ") : []

      total = item['TotalScore'].to_i
      events_url = item.fetch('Url', nil)

      extra = { 'doi' => doi,
                'f1000_id' => item.fetch('Id'),
                'url' => events_url,
                'score' => total,
                'classifications' => classifications }

      { source_id: "f1000",
        work_id: "doi:#{doi}",
        total: total,
        events_url: events_url,
        extra: extra }
    end
  end

  def config_fields
    [:url_private]
  end
end
