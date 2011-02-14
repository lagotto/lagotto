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

class Researchblogging < Source
  include SourceHelper
  
  def uses_username; true; end
  def uses_password; true; end
  def uses_search_url; true; end
  def uses_url; true; end
  
  def public_url_base
    "http://researchblogging.org/post-search/list?article="
  end

  def perform_query(article, options={})
    raise(ArgumentError, "Researchblogging configuration requires username & password") \
      if username.blank? or password.blank?

    furl = "#{url}?count=100&article=#{CGI.escape(article.doi)}"

    Rails.logger.info "Researchblogging query: #{furl}"

    get_xml(furl, options.merge(:username => username, :password => password)) do |xml|
      citations = []
      
      xml.find("//blogposts/post").each do |post|
        details = {}
        
        details[:title] = post.find_first("post_title").content
        details[:name] = post.find_first("blog_name").content
        details[:blogger_name] = post.find_first("blogger_name").content
        details[:publishdate] = post.find_first("published_date").content
        details[:receiveddate] = post.find_first("received_date").content
        
        citation = {}
        citation[:uri] = post.find_first("post_URL").content
        citation[:details] = details;
        
        Rails.logger.debug "citation uri: #{citation[:uri]}"
        
        citations << citation        
      end
      citations
    end
  end
end

