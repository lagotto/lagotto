# encoding: UTF-8

class CitationMilestoneAlert < Filter
  def run_filter(state)
    responses = ApiResponse.filter(state[:id]).citation_milestone(limit, source_ids)

    if responses.count > 0
      responses = responses.to_a.map do |response|
        { source_id: response.source_id,
          article_id: response.article_id,
          level: Alert::INFO,
          message: "Article has been cited #{response.event_count} times" }
      end
      raise_alerts(responses)
    end

    responses.count
  end

  def get_config_fields
    [{ field_name: "source_ids" },
     { field_name: "limit", field_type: "text_field", field_hint: "Creates an alert if an article has been cited the specified number of times." }]
  end

  def limit
    config.limit || 50
  end

  def source_ids
    config.source_ids || Source.active.joins(:group).where("groups.name" =>['cited', 'saved']).pluck(:id)
  end
end
