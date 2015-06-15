class HtmlRatioTooHighError < Filter
  def run_filter(state)
    responses = ApiResponse.filter(state[:id]).slow(limit)

    if responses.count > 0
      responses = responses.to_a.map do |response|
        ratio = response.pdf > 0 ? response.html / response.pdf : response.html
        { source_id: response.source_id,
          work_id: response.work_id,
          level: Alert::INFO,
          message: "HTML/PDF ratio is #{ratio} with #{response.html} views" }
      end
      raise_alerts(responses)
    end

    responses.count
  end

  def get_config_fields
    [{ field_name: "limit", field_type: "text_field", field_hint: "Raise an error if html to pdf ratio is higher than the specified value." }]
  end

  def limit
    config.limit || 50
  end

  def source_ids
    config.source_ids || Source.active.joins(:group).where("groups.name" => 'viewed').pluck(:id)
  end
end

module Exceptions
  class HtmlRatioTooHighError < ApiResponseError; end
end
