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

class PubMed < Source
  def get_data(article, options={})
    # First, we need to have the pmid for this article.
    # Get it if we don't have it, and proceed only if we do.
    return { events: [], event_count: nil } unless article.get_ids && article.pmid.present?

    # OK, we've got the IDs. Get the citations using the PubMed ID.
    events = []
    query_url = get_query_url(article)
    result = get_xml(query_url, options)

    # Check that PubMed has returned something, otherwise an error must have occured
    return nil if result.nil?

    result.xpath("//PMCID").each do |cite|
      pmc = cite.content
      if pmc
        event = {
          :event => pmc,
          :event_url => "http://www.pubmedcentral.nih.gov/articlerender.fcgi?artid=" + pmc
        }

        events << event
      end
    end

    events_url = get_events_url(article)

    { :events => events,
      :events_url => events_url,
      :event_count => events.length,
      :event_metrics => event_metrics(citations: events.length),
      :attachment => events.empty? ? nil : { :filename => "events.xml", :content_type => "text\/xml", :data => result.to_s } }
  end

  def get_query_url(article)
    url % { :pmid => article.pmid }
  end

  def get_events_url(article)
    "http://www.ncbi.nlm.nih.gov/sites/entrez?db=pubmed&cmd=link&LinkName=pubmed_pmc_refs&from_uid=#{article.pmid}"
  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"}]
  end

  def url
    config.url || "http://www.pubmedcentral.nih.gov/utils/entrez2pmcciting.cgi?view=xml&id=%{pmid}"
  end
end
