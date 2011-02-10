# $HeadURL: http://ambraproject.org/svn/plos/alm/head/app/models/sources/pub_med.rb $
# $Id: pub_med.rb 5865 2010-12-28 21:47:47Z jsong $
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

class PubMed < Source
  include SourceHelper

  ToolID = 'ArticleLevelMetrics'

  def perform_query(article, options={})

    # First, we need to have the PubMed and PubMedCentral IDs for this
    # article. Get 'em if we don't have 'em, and proceed only if we do.
    article.pub_med ||= get_pub_med_from_doi(article.doi, options)
    return [] unless article.pub_med
    article.pub_med_central ||= get_pub_med_central_from_pub_med(\
      article.pub_med, options)
    return [] unless article.pub_med_central

    if(article.pub_med_changed? || article.pub_med_central_changed?)
      article.save!
    end

    # OK, we've got the IDs. Get the citations using the PubMed ID.
    url = "http://www.pubmedcentral.nih.gov/utils/entrez2pmcciting.cgi?view=xml&id="
    citations = []
    query_url = url + article.pub_med
    
    get_xml(query_url, options.merge(:remove_doctype => 1)) do |document|
      document.find("//PubMedToPMCcitingformSET/REFORM/PMCID").each do |cite|
        pmc = cite.first.content
        if pmc
          citation = {
            :uri => "http://www.pubmedcentral.nih.gov/articlerender.fcgi?artid=" + pmc
          }
          citations << citation
        end
      end
    end
    citations
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
    query_url = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?" \
              + params.to_query
    result = get_xml(query_url, options.merge(:remove_doctype => 1)) \
        do |document|
      id_element = document.find_first("//eSearchResult/IdList/Id")
      id_element and id_element.content.strip
    end
    Rails.logger.debug "PM_from_DOI got #{result.inspect} for #{doi.inspect}" \
      if result
    result
  end

  def get_pub_med_central_from_pub_med(pubmed, options={})
    query_url = "http://www.pubmedcentral.nih.gov/utils/entrezpmc.cgi?view=xml&id=" + pubmed
    result = get_xml(query_url, options.merge(:remove_doctype => 1)) \
        do |document|
      id_element = document.find_first("//PubMedToPMCreformSET/REFORM/PMCID")
      id_element and id_element.content.strip
    end
    Rails.logger.debug "PMC_from_PM got #{result.inspect} for #{pubmed.inspect}" \
      if result
    result
  end

  def public_url(retrieval)
    pub_med_id = retrieval.article.pub_med 
    pub_med_id && ("http://www.ncbi.nlm.nih.gov/sites/entrez?db=pubmed&cmd=link&LinkName=pubmed_pmc_refs&from_uid=" + pub_med_id)
  end
end
