class EventCountDecreasingError < Filter
  def run_filter(state)
    responses = Change.filter(state[:id]).decreasing(source_ids)

    if responses.count > 0
      responses = responses.to_a.map do |response|
        { source_id: response.source_id,
          work_id: response.work_id,
          level: Notification::INFO,
          message: "Event count decreased from #{response.previous_total} to #{response.total}" }
      end
      raise_notifications(responses)
    end

    responses.count
  end

  def get_config_fields
    [{ field_name: "source_ids" }]
  end

  def source_ids
    config.source_ids || Source.active.joins(:group).where("groups.name" => ['cited', 'saved', 'recommended', 'viewed']).pluck(:id)
  end
end

module Exceptions
  class EventCountDecreasingError < ApiResponseError; end
end
