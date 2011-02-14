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

class Connotea < Source
  include SourceHelper
  
  def uses_username; true; end
  def uses_password; true; end
  def uses_search_url; true; end

  def perform_query(article, options={})
    raise(ArgumentError, "Connotea configuration requires username & password") \
      if username.blank? or password.blank?

    url = "http://www.connotea.org/data/uri/#{DOI::to_url article.doi}"
    
    Rails.logger.info "Connotea query: #{url}"
    
    get_xml(url, options.merge(:username => username, :password => password))\
        do |document|
      citations = []
      document.root.namespaces.default_prefix = 'default'
      document.find("//default:Post").each do |cite|
        uri = cite.find_first("@rdf:about").value
        citations << { :uri => uri }

        # Note Connotea's internal ID if we haven't already
        options[:retrieval].local_id ||= uri[uri.rindex('/')+1..-1]
      end
      citations
    end
  end

  def public_url(retrieval)
    retrieval.local_id && ("http://www.connotea.org/uri/" + retrieval.local_id)
  end
end
