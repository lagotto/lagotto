class PubMed < Source
  include SourceHelper

  def query(article, options={})

    # First, we need to have the PubMed and PubMedCentral IDs for this
    # article. Get 'em if we don't have 'em, and proceed only if we do.
    article.pub_med ||= get_pub_med_from_doi(article.doi, options)
    return [] unless article.pub_med
    article.pub_med_central ||= get_pub_med_central_from_pub_med(\
      article.pub_med, options)
    return [] unless article.pub_med_central

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
      'tool' => 'PLoSArticleMetrics', 
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
    puts "PM_from_DOI got #{result.inspect} for #{doi.inspect}" \
      if result and options[:verbose]
    result
  end

  def get_pub_med_central_from_pub_med(pubmed)
    query_url = "http://www.pubmedcentral.nih.gov/utils/entrezpmc.cgi?view=xml&id=" + pubmed
    result = get_xml(query_url, options.merge(:remove_doctype => 1)) \
        do |document|
      id_element = document.find_first("//PubMedToPMCreformSET/REFORM/PMCID")
      id_element and id_element.content.strip
    end
    puts "PMC_from_PM got #{result.inspect} for #{pubmed.inspect}" \
      if result and options[:verbose]
    result
  end
end
