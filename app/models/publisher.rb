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

class Publisher < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  has_many :users
  has_many :articles
  has_many :publisher_options, :dependent => :destroy
  has_many :sources, :through => :publisher_options

  serialize :prefixes
  serialize :other_names

  validates :name, :presence => true
  validates :crossref_id, :presence => true, :uniqueness => true

  def self.per_page
    15
  end

  def to_param  # overridden, use crossref_id instead of id
    crossref_id
  end

  def query(string, offset = 0, rows = 20)
    result = get_data(string, offset, rows)
    result = parse_data(result)
  end

  def query_url(string = "", offset = 0, rows = 20)
    url = "http://api.crossref.org/members?"
    params = { query: string, offset: offset, rows: rows }
    url + params.to_query
  end

  def get_data(string = "", offset = 0, rows = 20, options={})
    result = get_result(query_url(string, offset, rows), options)

    # extend hash fetch method to nested hashes
    result.extend Hashie::Extensions::DeepFetch
  end

  def parse_data(result)
    # return early if an error occured
    return result if result["status"] != "ok"

    items = result['message'] && result.deep_fetch('message', 'items') { nil }
    publishers = Array(items).map do |item|
      Publisher.new do |publisher|
        publisher.name = item["primary-name"]
        publisher.crossref_id = item["id"]
        publisher.prefixes = item["prefixes"]
        publisher.other_names = item["names"]
      end
    end

    # return the number of total hits, plus an array of unsaved ActiveRecord objects
    { total_entries: result.deep_fetch('message', 'total-results') { 0 },
      publishers: publishers }
  end
end
