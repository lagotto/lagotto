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

class Openedition < Source
  def request_options
    { content_type: 'xml' }
  end

  def get_events(result)
    result['RDF']['item'] = [result['RDF']['item']] if result['RDF']['item'].is_a?(Hash)
    Array(result['RDF']['item']).map do |item|
      { event: item,
        event_time: get_iso8601_from_time(item["date"]),
        event_url: item['link'] }
    end
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    config.url || "http://search.openedition.org/feed.php?op[]=AND&q[]=%{doi}&field[]=All&pf=Hypotheses.org"
  end

  def events_url
    config.events_url || "http://search.openedition.org/index.php?op[]=AND&q[]=%{doi}&field[]=All&pf=Hypotheses.org"
  end

  def staleness_year
    config.staleness_year || 1.month
  end

  def rate_limiting
    config.rate_limiting || 1000
  end
end
