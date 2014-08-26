# encoding: UTF-8

class ArticleNotUpdatedError < Filter
  def run_filter(state)
    responses = ApiResponse.filter(state[:id]).article_not_updated(limit)

    if responses.count > 0
      responses = responses.all.map do |response|
        { source_id: response.source_id,
          article_id: response.article_id,
          level: Alert::ERROR,
          message: "Article not updated for #{response.update_interval} days" }
      end
      raise_alerts(responses)
    end

    responses.count
  end

  def get_config_fields
    [{ field_name: "limit", field_type: "text_field", field_hint: "Raises an error if articles have not been updated within the specified interval in days" }]
  end

  def limit
    config.limit || 40
  end
end

module Exceptions
  class ArticleNotUpdatedError < ApiResponseError; end
end
