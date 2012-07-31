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

  ToolID = 'ArticleLevelMetrics'

  validates_each :url do |record, attr, value|
    record.errors.add(attr, "can't be blank") if value.blank?
  end

  def get_data(article, options={})

    # First, we need to have the PubMed and PubMedCentral IDs for this
    # article. Get 'em if we don't have 'em, and proceed only if we do.
    article.pub_med ||= get_pub_med_from_doi(article.doi, options)
    return [] unless article.pub_med

    article.pub_med_central ||= get_pub_med_central_from_pub_med(article.pub_med, options)
    return [] unless article.pub_med_central

    if article.changed?
      article.save
    end

    # OK, we've got the IDs. Get the citations using the PubMed ID.
    events = []
    query_url = get_query_url(article)

    get_xml(query_url, options.merge(:remove_doctype => 1)) do |document|
      document.find("//PubMedToPMCcitingformSET/REFORM/PMCID").each do |cite|
        pmc = cite.first.content
        if pmc
          event = {
              :event => pmc,
              :event_url => "http://www.pubmedcentral.nih.gov/articlerender.fcgi?artid=" + pmc
          }

          events << event
        end
      end

      events_url = "http://www.ncbi.nlm.nih.gov/sites/entrez?db=pubmed&cmd=link&LinkName=pubmed_pmc_refs&from_uid=#{article.pub_med}"
      xml_string = document.to_s(:encoding => XML::Encoding::UTF_8)

      {:events => events,
       :events_url => events_url,
       :event_count => events.length,
       :attachment => {:filename => "events.xml", :content_type => "text\/xml", :data => xml_string }
      }

    end
  end

  def get_pub_med_from_doi(doi, options={})
    params = {
        'term' => doi,
        'field' => 'aid', # just search the article ID field
        'db' => 'pubmed',
        'tool' => PubMed::ToolID,
        'usehistory' => 'n',
        'retmax' => 1
    }
    query_url = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?" + params.to_query

    result = get_xml(query_url, options.merge(:remove_doctype => 1)) do |document|
      id_element = document.find_first("//eSearchResult/IdList/Id")
      id_element and id_element.content.strip
    end
    Rails.logger.debug "PM_from_DOI got #{result.inspect} for #{doi.inspect}" if result
    result
  end

  def get_pub_med_central_from_pub_med(pubmed, options={})
    query_url = "http://www.pubmedcentral.nih.gov/utils/entrezpmc.cgi?view=xml&id=" + pubmed
    result = get_xml(query_url, options.merge(:remove_doctype => 1)) do |document|
      id_element = document.find_first("//PubMedToPMCreformSET/REFORM/PMCID")
      id_element and id_element.content.strip
    end
    Rails.logger.debug "PMC_from_PM got #{result.inspect} for #{pubmed.inspect}" if result
    result
  end

  def get_query_url(article)
    config.url % { :pub_med => article.pub_med }
  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"}]
  end

  def url
    config.url
  end

  def url=(value)
    config.url = value
  end

end
