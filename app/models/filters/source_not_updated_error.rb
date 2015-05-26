class SourceNotUpdatedError < Filter
  def run_filter(state)
    responses_by_source = Change.filter(state[:id]).group(:source_id).count
    responses = source_ids.select { |source_id| !responses_by_source.key?(source_id) }

    if responses.count > 0
      # send additional report, listing all stale sources by name
      report = Report.where(name: "stale_source_report").first
      report.send_stale_source_report(responses)

      responses = responses.map do |response|
        { source_id: response,
          message: "Source not updated for 24 hours" }
      end
      raise_notifications(responses)
    end

    responses.count
  end

  def get_config_fields
    [{ field_name: "source_ids" }]
  end

  def source_ids
    config.source_ids || Source.active.where("name != ?", 'pmc').pluck(:id)
  end
end

module Exceptions
  class SourceNotUpdatedError < ApiResponseError; end
end
