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
  
  EUTILS_URL = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?"
  ESUMMARY_URL = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?"
  PMCLINKS_URL = "http://www.ncbi.nlm.nih.gov/sites/entrez?"
  PMC_URL = "http://www.ncbi.nlm.nih.gov/pmc/articles/"
  
  ToolID = 'ArticleLevelMetrics'

  validates_each :url do |record, attr, value|
    record.errors.add(attr, "can't be blank") if value.blank?
  end

  def get_data(article, options={})
    # First, we need to have the PMID for this article. 
    # Get it if we don't have it, and proceed only if we do.
    # We need a DOI to fetch the PMID
    if article.pub_med.blank?
      return  { :events => [], :event_count => 0 } if article.doi.blank? 
      article.pub_med = get_pmid_from_doi(article.doi, options)
      return  { :events => [], :event_count => 0 } if article.pub_med.blank?
    end

    # Also get the PMCID, but wait until one month after publication
    if Time.zone.now - article.published_on.to_time >= 1.month
      article.pub_med_central = get_pmcid_from_doi(article.doi, options) if article.pub_med_central.blank?
    end
    
    if article.changed?
      article.save
    end

    # OK, we've got the PMID, now get the citations.
    query_url = get_query_url(article)

    get_xml(query_url, options) do |document|
      result = Hash.from_xml(document.to_s(:encoding => XML::Encoding::UTF_8))
      result = result["PubMedToPMCcitingformSET"]["REFORM"]["PMCID"]
      if result.nil?
        { :events => [], :event_count => 0 }
      else
        # Retrieve more information about these PMCIDs.
        result = get_summary_from_pubmed(result)
                
        events = []
        result.each do |event|
          url = PMC_URL + event[:pmcid]
          events << {:event => event, :event_url => url}
        end
        
        params = {
            'from_uid' => article.pub_med,
            'db' => 'pubmed',
            'cmd' => 'link',
            'LinkName' => 'pubmed_pmc_refs',
            'tool' => PubMed::ToolID }
        events_url = PMCLINKS_URL + params.to_query
        
        xml_string = document.to_s(:encoding => XML::Encoding::UTF_8)

        {:events => events,
         :events_url => events_url,
         :event_count => events.length,
         :attachment => {:filename => "events.xml", :content_type => "text\/xml", :data => xml_string }}
      end
    end
  end

  def get_pmid_from_doi(doi, options={})
    params = {
        'term' => doi,
        'field' => 'DOI',
        'db' => 'pubmed',
        'tool' => PubMed::ToolID }
        
    query_url = EUTILS_URL + params.to_query

    result = get_xml(query_url, options.merge(:remove_doctype => 1)) do |document|
      id_element = document.find_first("//eSearchResult/IdList/Id")
      id_element and id_element.content.strip
    end
  end
  
  def get_pmcid_from_doi(doi, options={})
    params = {
        'term' => doi,
        'field' => 'DOI',
        'db' => 'pmc',
        'tool' => PubMed::ToolID }
        
    query_url = EUTILS_URL + params.to_query

    result = get_xml(query_url, options.merge(:remove_doctype => 1)) do |document|
      id_element = document.find_first("//eSearchResult/IdList/Id")
      id_element and id_element.content.strip
    end
  end
  
  def get_summary_from_pubmed(pubmed_ids, options={})
    db = options[:db] || "pmc"
    
    params = {
        'id' => [*pubmed_ids].join(","),
        'db' => db,
        'version' => '2.0',
        'tool' => PubMed::ToolID }
        
    query_url = ESUMMARY_URL + params.to_query
    
    get_xml(query_url, options.merge(:remove_doctype => 1)) do |document| 
      references = []
      result = Hash.from_xml(document.to_s(:encoding => XML::Encoding::UTF_8))
      result = result["eSummaryResult"]["DocumentSummarySet"]["DocumentSummary"]
      result = [result] unless result.is_a?(Array)
      result.each do |document_summary|
        ids = document_summary["ArticleIds"]["ArticleId"].map { |article_id| { article_id["IdType"] => article_id["Value"] }.symbolize_keys }
        ids = ids.inject { | a, h | a.merge h }
        published_on = parse_date([document_summary["EPubDate"],document_summary["PubDate"],document_summary["SortDate"],document_summary["SortPubDate"]])
        references << ids.merge({ :title => document_summary["Title"],
                                  :published_on => published_on })
      end
      references
    end
  end
  
  def parse_date(dates)
    dates.each do |date|
      begin
        return Date.parse(date).to_s(:db)
      rescue
      end
    end
  end

  def get_query_url(article)
    url % { :pub_med => article.pub_med } unless article.pub_med.blank?
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