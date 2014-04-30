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
  def get_query_url(article)
    return nil unless article.get_ids && article.pmid.present?

    url % { :pmid => article.pmid }
  end

  def request_options
    { content_type: 'xml' }
  end

  def get_events(result)
    Array(result['PubMedToPMCcitingformSET']['REFORM']['PMCID']).map do |item|
      { :event => item, :event_url => "http://www.pubmedcentral.nih.gov/articlerender.fcgi?artid=" + item }
    end
  end

  def get_events_url(article)
    if article.pmid.present?
      events_url % { :pmid => article.pmid }
    else
      nil
    end
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    config.url || "http://www.pubmedcentral.nih.gov/utils/entrez2pmcciting.cgi?view=xml&id=%{pmid}"
  end

  def events_url
    config.events_url || "http://www.ncbi.nlm.nih.gov/sites/entrez?db=pubmed&cmd=link&LinkName=pubmed_pmc_refs&from_uid=%{pmid}"
  end
end
