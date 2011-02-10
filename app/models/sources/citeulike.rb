# $HeadURL: http://ambraproject.org/svn/plos/alm/head/app/models/sources/citeulike.rb $
# $Id: citeulike.rb 5693 2010-12-03 19:09:53Z josowski $
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

class Citeulike < Source
  include SourceHelper
  
  def uses_search_url; true; end

  def perform_query(article, options={})

    url = "http://www.citeulike.org/api/posts/for/doi/#{CGI.escape(article.doi)}"
    
    Rails.logger.info "Citeulike query: #{url}"
    
    get_xml(url, options) do |document|
      citations = []
      document.find("//posts/post").each do |cite|
        link = cite.find_first("link")
        post_time = cite.find_first("post_time")
        tags = []
        cite.find("tag").each do |tag|
          tags << tag.content
        end

        citation = {}
        citation[:username] = cite.attributes['username']
        citation[:articleid] = cite.attributes['article_id']
        citation[:post_time] = post_time.content
        citation[:tags] = tags.join ', ' 
        citation[:uri] = link.attributes['url']
	
        citations << citation

        # Note CiteULike's internal ID if we haven't already
        options[:retrieval].local_id ||= citation[:articleid]
      end
      citations
    end
  end

  def public_url(retrieval)
    retrieval.local_id && ("http://www.citeulike.org/article-posts/" \
                           + retrieval.local_id)
  end
  
end

