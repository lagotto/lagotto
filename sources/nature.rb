# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2010 by Public Library of Science, a non-profit corporation
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

class Nature < Source
  include SourceHelper
  
  def uses_search_url; true; end

  def perform_query(article, options={})
    url = "http://blogs.nature.com/posts.json?doi="
    
    Rails.logger.info "Nature query: #{url}"
    
    query_url = url + CGI.escape(article.doi)
    results = get_json(query_url, options)
    citations = results.map do |result|
      # The body's huge - don't bother saving it.
      result["post"].delete("body")

      # Every citation has to have a URI - make one from the URL, 
      # which probably doesn't begin with "http://" (ugh).
      uri = result["post"].delete("url")
      uri = "http://#{uri}" unless uri.start_with?("http://")
      result[:uri] = uri

      result
    end
    citations
  end

  def public_url_base
    "http://blogs.nature.com/posts?doi="
  end
end
