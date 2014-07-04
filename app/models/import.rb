# encoding: UTF-8

# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2014 by Public Library of Science, a non-profit corporation
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

class Import
  # include HTTP request helpers
  include Networkable

  attr_accessor :filter, :rows, :offset

  def initialize(options = {})
    from_index_date = options.fetch(:from_index_date, Date.yesterday.to_s(:db))
    until_index_date = options.fetch(:until_index_date, Date.yesterday.to_s(:db))
    type = options.fetch(:type, 'journal-article')
    member = options.fetch(:member, nil)

    @filter = "from-index-date:#{from_index_date}"
    @filter += ",until-index-date:#{until_index_date}"
    @filter += ",type:#{type}"
    @filter += ",member:#{member}" if member
    @rows = options.fetch(:rows, 500)
    @offset = options.fetch(:offset, 0)
  end

  def query_url
    url = "http://api.crossref.org/works?"
    params = { filter: @filter,
               rows: @rows,
               offset: @offset }
    url + params.to_query
  end

  def get_data(options={})
    result = get_result(query_url, options)

    # extend hash fetch method to nested hashes
    result.extend Hashie::Extensions::DeepFetch
  end

  def parse_data(result, options = {})
    # return early if an error occured
    return result if result["status"] != "ok"

    articles = result['message'] && result.deep_fetch('message', 'items') { nil }
    Array(articles).map do |item|
      date_parts = item["issued"]["date-parts"][0]
      year, month, day = date_parts[0], date_parts[1], date_parts[2]

      { doi: item["DOI"],
        title: item["title"][0],
        year: year,
        month: month,
        day: day }
    end
  end
end
