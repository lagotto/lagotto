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

class Citeulike < Source
  def request_options
    { content_type: 'xml' }
  end

  def response_options
    { metrics: :shares }
  end

  def get_events(result)
    result['posts'] ||= {}
    Array(result['posts']['post']).map do |item|
      { :event => item, :event_url => item['link']['url'] }
    end
  end

  protected

  def config_fields
    [:url, :events_url]
  end

  def url
    config.url  || "http://www.citeulike.org/api/posts/for/doi/%{doi}"
  end

  def events_url
    config.events_url  || "http://www.citeulike.org/doi/%{doi}"
  end

  def rate_limiting
    config.rate_limiting || 2000
  end
end
