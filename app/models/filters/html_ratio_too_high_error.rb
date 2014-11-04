# encoding: UTF-8

class HtmlRatioTooHighError < Filter
  def run_filter(state)
    source = Source.where(name: "counter").first
    first_response = ApiResponse.filter(state[:id]).first
    responses = first_response.get_html_ratio

    if responses.count > 0
      responses = responses.map do |response|
        doi = response['id'] && response['id'][8..-1]
        article = Article.where(doi: doi).first
        article_id = article && article.id
        date = Date.today.to_formatted_s(:short)

        { source_id: source.id,
          article_id: article_id,
          level: Alert::INFO,
          message: "HTML/PDF ratio is #{response['value']['ratio']} with #{response['value']['html']} HTML views on #{date}" }
      end
      raise_alerts(responses)
    end

    responses.count
  end
end

module Exceptions
  class HtmlRatioTooHighError < ApiResponseError; end
end
