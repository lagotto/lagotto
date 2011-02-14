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

class Bloglines < Source
  include SourceHelper
  
  def uses_username; true; end
  def uses_password; true; end
  def uses_search_url; true; end

  def perform_query(article, options={})
    raise(ArgumentError, "Bloglines configuration requires username & password") \
      if username.blank? or password.blank?

    url = "http://www.bloglines.com/search?format=publicapi&apiuser=#{username}&apikey=#{password}&q=#{CGI.escape(article.title).strip_tags}"
    
    Rails.logger.info "Bloglines query: #{url}"
    
    get_xml(url, options) do |document|
      citations = []
      document.find("//resultset/result").each do |cite|
        citation = {}
        %w[site/name site/url site/feedurl title author abstract url].each do |a|
          first = cite.find_first("#{a}")
          if first
            citation[a.gsub('/','_').intern] = first.content
          end
        end
        citation[:uri] = citation.delete(:url)
        # Ignore citations of the dx.doi.org URI itself
        citations << citation \
          unless DOI::from_uri(citation[:uri]) == article.doi
      end
      citations
    end
  end
end
