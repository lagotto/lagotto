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

class CrossRef < Source
  include SourceHelper
  
  def uses_username; true; end
  def uses_password; true; end

  def perform_query(article, options={})
    raise(ArgumentError, "Crossref configuration requires username & password") \
      if username.blank? or password.blank?

    url = "http://doi.crossref.org/servlet/getForwardLinks?usr=" + username + "&pwd=" + password + "&doi="
    
    Rails.logger.info "CrossRef query: #{url}"

    get_xml(url + CGI.escape(article.doi), options) do |document|
      document.root.namespaces.default_prefix = "x"
      citations = []
      document.find("//x:journal_cite").each do |cite|
        citation = {}
        %w[doi journal_title journal_abbreviation article_title volume issue first_page year].each do |a|
          first = cite.find_first("x:#{a}")
          if first
            content = first.content
            citation[a.intern] = content
          end
        end
        if citation[:doi]
          contributors_element = cite.find_first("x:contributors")
          citation[:contributors] = extract_contributors(contributors_element) \
            if contributors_element

          citation[:uri] = DOI::to_url(citation[:doi])
          citations << citation
        end
      end
      citations
    end
  end

protected
  def extract_contributors(contributors_element)
    contributors = []
    contributors_element.find("x:contributor").each do |c|
      surname = c.find_first("x:surname")
      surname = surname.content if surname
      given_name = c.find_first("x:given_name")
      given_name = given_name.content if given_name
      given_name = given_name.split.map { |w| w.first.upcase }.join("") \
        if given_name
      contributor = [surname, given_name].compact.join(" ")
      if c.attributes['first-author'] == 'true'
        contributors.unshift contributor
      else
        contributors << contributor
      end
    end
    contributors.join(", ")
  end
end
