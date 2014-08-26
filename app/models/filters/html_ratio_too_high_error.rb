# encoding: UTF-8

class HtmlRatioTooHighError < Filter
  def run_filter(state)
    source = Source.find_by_name("counter")
    first_response = ApiResponse.filter(state[:id]).first
    responses = first_response.get_html_ratio

    if responses.count > 0
      responses = responses.map do |response|
        doi = response['id'] && response['id'][8..-1]
        article = Article.find_by_doi(doi)
        article_id = article && article.id

        { source_id: source.id,
          article_id: article_id,
          level: Alert::WARN,
          message: "HTML/PDF ratio is #{response['value']['ratio']} with #{response['value']['html']} HTML views this month" }
      end
      raise_alerts(responses)
    end

    responses.count
  end
end

module Exceptions
  class HtmlRatioTooHighError < ApiResponseError; end
end
