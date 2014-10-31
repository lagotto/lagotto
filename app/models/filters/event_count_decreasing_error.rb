# encoding: UTF-8

class EventCountDecreasingError < Filter
  def run_filter(state)
    responses = ApiResponse.filter(state[:id]).decreasing(source_ids)

    if responses.count > 0
      responses = responses.all.map do |response|
        { source_id: response.source_id,
          article_id: response.article_id,
          level: Alert::INFO,
          message: "Event count decreased from #{response.previous_count} to #{response.event_count}" }
      end
      raise_alerts(responses)
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
