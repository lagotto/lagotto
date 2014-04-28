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

class Datacite < Source
  def get_events(result)
    result["response"] ||= {}
    Array(result["response"]["docs"]).map { |item| { event: event, event_url: "http://doi.org/#{event['doi']}" } }
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    config.url || "http://search.datacite.org/api?q=relatedIdentifier:%{doi}&fl=relatedIdentifier,doi,creator,title,publisher,publicationYear&fq=is_active:true&fq=has_metadata:true&indent=true&rows=100&wt=json"
  end

  def events_url
    config.events_url || "http://search.datacite.org/ui?q=relatedIdentifier:%{doi}"
  end
end
