# encoding: UTF-8

# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2012 by Public Library of Science, a non-profit corporation
# http://www.plos.org/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
