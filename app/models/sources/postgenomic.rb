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

class Postgenomic < Source
  def get_data(article, options={})
    query_url = get_query_url(article)

    result = get_result(query_url, options)

    events = result.map do |item|
      { :event => item, :event_url => item["url"] }
    end

    events_url = get_events_url(article)

    { :events => events,
      :events_url => events_url,
      :event_count => events.length }
  end

  def get_events_url(article)
    unless article.doi.blank?
      "http://postgenomic.com/paper.php?doi=#{Addressable::URI.encode(article.doi)}"
    else
      nil
    end
  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"}]
  end

  def obsolete?
    true
  end
end
