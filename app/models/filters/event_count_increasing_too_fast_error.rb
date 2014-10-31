# encoding: UTF-8

class EventCountIncreasingTooFastError < Filter
  def run_filter(state)
    responses = ApiResponse.filter(state[:id]).increasing(limit, source_ids)

    if responses.count > 0
      responses = responses.all.map do |response|
        { source_id: response.source_id,
          article_id: response.article_id,
          level: Alert::INFO,
          message: "Event count increased by #{response.event_count - response.previous_count} in #{response.update_interval} day(s)" }
      end
      raise_alerts(responses)
    end

    responses.count
  end

  def get_config_fields
    [{ field_name: "source_ids" },
     { field_name: "limit", field_type: "text_field", field_hint: "Raises an error if the event count increases faster than the specified value per day." }]
  end

  def limit
    config.limit || 500
  end

  def source_ids
    config.source_ids || Source.active.joins(:group).where("groups.name" => ['viewed', 'discussed']).pluck(:id)
  end
end

module Exceptions
  class EventCountIncreasingTooFastError < ApiResponseError; end
end
