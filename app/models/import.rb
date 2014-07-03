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
  attr_accessor :filter, :rows, :offset

  def initialize(options = {})
    from_pub_date = options.fetch(:from_pub_date, Date.yesterday.to_s(:db))
    until_pub_date = options.fetch(:until_pub_date, Date.today.to_s(:db))
    member = options.fetch(:member, nil)

    @filter = "from-pub-date:#{from_pub_date},until-pub-date:#{until_pub_date}"
    @filter += ",member:#{member}" if member
    @rows = options.fetch(:rows, 500)
    @offset = options.fetch(:offset, 0)
  end

  def query_url
    url = "http://api.crossref.org/works?"
    params = { filter: @filter,
               rows: @rows,
               offset: @offset,
               sort: "published",
               order: "asc" }
    url + params.to_query
  end

  def get_data(options={})
    result = get_result(query_url, options)

    # extend hash fetch method to nested hashes
    result.extend Hashie::Extensions::DeepFetch
  end
end
