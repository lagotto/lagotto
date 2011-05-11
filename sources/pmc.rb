# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2011 by Public Library of Science, a non-profit corporation
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

class Pmc < Source

  def uses_misc; true; end
  
  def perform_query(article, options)
    raise(ArgumentError, "PMC configuration requires filepath") \
      if misc.blank?

    # get the file path to the xml file that contains the data from PMC
    config = YAML.parse(misc)
    filepath = config["filepath"]
    filepath = filepath.transform

    parser = XML::Parser.file(filepath)
    
    document = parser.parse

    month = 0
    year = 0
    # there is only one articles element
    document.find("/articles").each do | articles |
      month = articles.attributes['month']
      year = articles.attributes['year']
    end
    
    views = []
    # get all the previously added data.  the new data will be appended to the views array
    retrieval = Retrieval.find_by_article_id_and_source_id(article.id, self.id)      
    retrieval.citations.each do |citation|            
      if(citation.details != nil)
        existing_views = citation.details.fetch(:views)

        existing_views.each do | view |
          existing_view = {}
          existing_view['year'] = view.fetch('year')
          existing_view['month'] = view.fetch('month')
          existing_view['unique-ip'] = view.fetch('unique-ip')
          existing_view['full-text'] = view.fetch('full-text')
          existing_view['pdf'] = view.fetch('pdf')
          existing_view['abstract'] = view.fetch('abstract')
          existing_view['scanned-summary'] = view.fetch('scanned-summary')
          existing_view['scanned-page-browse'] = view.fetch('scanned-page-browse')
          existing_view['figure'] = view.fetch('figure')
          existing_view['supp-data'] = view.fetch('supp-data')
          existing_view['cited-by'] = view.fetch('cited-by')
          
          if (month.eql?(existing_view['month']) && year.eql?(existing_view['year'])) 
            # don't append, this is the data that is going to be added
          else            
            # append the existing data
            views << existing_view
          end
        end
      end
    end    

    document.find("//article/meta-data[@doi='#{article.doi}']").each do | metadata |
      
      article_document = metadata.parent

      view = {}
      usage = article_document.find_first("usage")
      attributes = usage.attributes
      view['year'] = year
      view['month'] = month
      view['unique-ip'] = attributes['unique-ip']
      view['full-text'] = attributes['full-text']
      view['pdf'] = attributes['pdf']
      view['abstract'] = attributes['abstract']
      view['scanned-summary'] = attributes['scanned-summary']
      view['scanned-page-browse'] = attributes['scanned-page-browse']
      view['figure'] = attributes['figure']
      view['supp-data'] = attributes['supp-data']
      view['cited-by'] = attributes['cited-by']

      # append the new data
      views << view
    end

    citations = []
    if (views.size > 0)
      citation = {}
      citation[:uri] = "http://dx.doi.org/" + article.doi
      citation[:views] = views;

      citations << citation
    end

    citations
  end  
  
  def citations_to_csv(csv, retrieval)
    
    csv << [ "uri", "year", "month", "unique-ip", "full-text", "pdf", "abstract", "scanned-summary",
             "scanned-page-browse", "figure", "supp-data", "cited-by" ]
    
    retrieval.citations.each do |citation|
      if(citation.details != nil)
        uri = citation.details.fetch(:uri)
        views = citation.details.fetch(:views)
        
        views.each do | view |
          csv << [ uri, view.fetch('year'), view.fetch('month'), view.fetch('unique-ip'), view.fetch('full-text'),
                   view.fetch('pdf'), view.fetch('abstract'), view.fetch('scanned-summary'),
                   view.fetch('scanned-page-browse'), view.fetch('figure'), view.fetch('supp-data'),
                   view.fetch('cited-by') ]
        end
      end  
    end
  end

end
