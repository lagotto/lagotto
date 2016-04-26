class F1000 < Agent
  def get_query_url(options={})
    fail ArgumentError, "Agent url is missing." if url_private.blank?

    url_private
  end

  def queue_jobs(options={})
    return 0 unless active?

    unless options[:all]
      return 0 unless stale?
    end

    query_url = get_query_url(options)
    result = get_result(query_url, options)
    total = result.fetch("ObjectList", []).fetch("Article", []).length

    if total > 0
      # walk through paginated results
      total_pages = (total.to_f / job_batch_size).ceil

      (0...total_pages).each do |page|
        AgentJob.set(queue: queue, wait_until: schedule_at).perform_later(self, options)
      end

      schedule_next_run
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

    return [result] if result[:error]

    items = result.fetch("ObjectList", {}).fetch("Article", [])
    get_relations_with_related_works(items)
  end

  def get_relations_with_related_works(items)
    Array(items).map do |item|
      doi = item.fetch('Doi', nil)
      url = item.fetch('Url', nil)

      # sometimes doi metadata are missing
      if doi.blank? || url.blank?
        nil
      else
        # turn classifications into array with lowercase letters
        # classifications = item['Classifications'] ? item['Classifications'].downcase.split(", ") : []

        total = item.fetch('TotalScore', 1).to_i

        subj = { "pid" => url,
                 "title" => "F1000 Prime recommendation for DOI #{doi}",
                 "container-title" => "F1000 Prime",
                 "issued" => Time.zone.now.utc.iso8601,
                 "type" => "entry",
                 "tracked" => tracked,
                 "registration_agency_id" => "f1000" }

        { prefix: doi[/^10\.\d{4,5}/],
          relation: { "subj_id" => subj["pid"],
                      "obj_id" => doi_as_url(doi),
                      "relation_type_id" => "recommends",
                      "total" => total,
                      "source_id" => source_id },
          subj: subj }
      end
    end.compact
  end

  def config_fields
    [:url_private]
  end
end
