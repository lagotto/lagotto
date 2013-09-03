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

  EUTILS_URL = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?"
  ESUMMARY_URL = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?"
  PMCLINKS_URL = "http://www.ncbi.nlm.nih.gov/sites/entrez?"
  PMC_URL = "http://www.ncbi.nlm.nih.gov/pmc/articles/"

  ToolID = 'ArticleLevelMetrics'

  validates_not_blank(:url)

  def get_data(article, options={})

    # First, we need to have the PMID for this article.
    # Get it if we don't have it, and proceed only if we do.
    # We need a DOI to fetch the PMID
    if article.pub_med.blank?
      return  { :events => [], :event_count => nil } if article.doi.blank?
      article.pub_med = get_pmid_from_doi(article.doi, options)
      return  { :events => [], :event_count => nil } if article.pub_med.blank?
    end

    # Also get the PMCID, but wait until one month after publication
    if Time.zone.now - article.published_on.to_time >= 1.month
      article.pub_med_central = get_pmcid_from_doi(article.doi, options) if article.pub_med_central.blank?
    end

    article.save if article.changed?

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

    event_metrics = { :pdf => nil,
                      :html => nil,
                      :shares => nil,
                      :groups => nil,
                      :comments => nil,
                      :likes => nil,
                      :citations => events.length,
                      :total => events.length }

    events_url = "http://www.ncbi.nlm.nih.gov/sites/entrez?db=pubmed&cmd=link&LinkName=pubmed_pmc_refs&from_uid=#{article.pub_med}"

    { :events => events,
      :events_url => events_url,
      :event_count => events.length,
      :event_metrics => event_metrics,
      :attachment => events.empty? ? nil : {:filename => "events.xml", :content_type => "text\/xml", :data => result.to_s }}
  end

  def get_pmid_from_doi(doi, options={})
    params = {
        'term' => doi,
        'field' => 'DOI',
        'db' => 'pubmed',
        'tool' => PubMed::ToolID }

    query_url = EUTILS_URL + params.to_query
    result = get_xml(query_url, options)

    return nil if result.blank?

    id_element = result.at_xpath("//eSearchResult/IdList/Id")
    id_element and id_element.content.strip
  end

  def get_pmcid_from_doi(doi, options={})
    params = {
        'term' => doi,
        'field' => 'DOI',
        'db' => 'pmc',
        'tool' => PubMed::ToolID }

    query_url = EUTILS_URL + params.to_query

    result = get_xml(query_url, options)

    return nil if result.blank?

    id_element = result.at_xpath("//eSearchResult/IdList/Id")
    id_element and id_element.content.strip
  end

  def get_summary_from_pubmed(pubmed_ids, options={})
    db = options[:db] || "pmc"

    params = {
        'id' => [*pubmed_ids].join(","),
        'db' => db,
        'version' => '2.0',
        'tool' => PubMed::ToolID }

    query_url = ESUMMARY_URL + params.to_query
    result = get_xml(query_url, options)
      references = []
      result = Nori.new.parse(result.to_s)
      result = result["eSummaryResult"]["DocumentSummarySet"]["DocumentSummary"]
      result = [result] unless result.is_a?(Array)
      result.each do |document_summary|
        ids = document_summary["ArticleIds"]["ArticleId"].map { |article_id| { article_id["IdType"] => article_id["Value"] }.symbolize_keys }
        ids = ids.inject { | a, h | a.merge h }
        publication_date = parse_date([document_summary["EPubDate"],document_summary["PubDate"],document_summary["SortDate"],document_summary["SortPubDate"]]).to_time.utc.iso8601
        references << ids.merge({ :title => document_summary["Title"],
                                  :publication_date => publication_date })
      end
      references
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
