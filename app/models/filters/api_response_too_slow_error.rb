# encoding: UTF-8

class ApiResponseTooSlowError < Filter
  def run_filter(state)
    responses = ApiResponse.filter(state[:id]).slow(limit)

    if responses.count > 0
      responses = responses.to_a.map do |response|
        { source_id: response.source_id,
          work_id: response.work_id,
          level: Alert::WARN,
          message: "API response took #{response.duration} ms" }
      end
      raise_alerts(responses)
    end

    responses.count
  end

  def get_config_fields
    [{ field_name: "limit", field_type: "text_field", field_hint: "Raise an error if successful API responses took longer than the specified time in seconds." }]
  end

  def limit
    config.limit || 30
  end
end

module Exceptions
  class ApiResponseTooSlowError < ApiResponseError; end
end
