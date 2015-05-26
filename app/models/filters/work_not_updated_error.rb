class WorkNotUpdatedError < Filter
  def run_filter(state)
    responses = Change.filter(state[:id]).work_not_updated(limit)

    if responses.count > 0
      responses = responses.to_a.map do |response|
        { source_id: response.source_id,
          work_id: response.work_id,
          level: Notification::ERROR,
          message: "Work not updated for #{response.update_interval} days" }
      end
      raise_notifications(responses)
    end

    responses.count
  end

  def get_config_fields
    [{ field_name: "limit", field_type: "text_field", field_hint: "Raises an error if works have not been updated within the specified interval in days" }]
  end

  def limit
    config.limit || 40
  end
end

module Exceptions
  class WorkNotUpdatedError < ApiResponseError; end
end
