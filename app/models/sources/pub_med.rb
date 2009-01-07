
class PubMed < Source
  include SourceHelper

  def uses_url; true; end

  def query(article)
    raise(ArgumentError, "PubMed configuration requires URL") \
      if url.blank?

    # First, we need to have the PubMed and PubMedCentral IDs for this
    # article. Get 'em if we don't have 'em, and proceed only if we do.
    article.pub_med ||= get_pub_med_from_doi(article.doi)
    return [] unless article.pub_med
    article.pub_med_central ||= get_pub_med_central_from_pub_med(article.pub_med)
    return [] unless article.pub_med_central

    # OK, we've got the IDs. Get the citations using the PubMedCentral ID.
    citations = []
    query_url = url + article.doi
    get_xml(query_url, :remove_doctype => 1) do |document|
      document.find("//PubMedToPMCcitingformSET/REFORM/PMCID").each do |cite|
        pmc = cite.first.content
        if pmc
          citation = {
            :uri => "http://www.ncbi.nlm.nih.gov/sites/entrez?cmd=Retrieve&db=pubmed&list_uids=" + pmc
          }
          citations << citation
        end
      end
    end
    citations
  end

  def get_pub_med_from_doi(doi)
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
    result = get_xml(query_url, :remove_doctype => 1) do |document|
      id_element = document.find_first("//eSearchResult/IdList/Id")
      id_element and id_element.content.strip
    end
    puts "PM_from_DOI got #{result.inspect} for #{doi.inspect}" \
      unless result.nil?
    result
  end

  def get_pub_med_central_from_pub_med(pubmed)
    query_url = "http://www.pubmedcentral.nih.gov/utils/entrezpmc.cgi?view=xml&id=" + pubmed
    result = get_xml(query_url, :remove_doctype => 1) do |document|
      id_element = document.find_first("//PubMedToPMCreformSET/REFORM/PMCID")
      id_element and id_element.content.strip
    end
    puts "PMC_from_PM got #{result.inspect} for #{pubmed.inspect}" \
      unless result.nil?
    result
  end

  def test
    article = Article.new(:doi => "10.1371/journal.pcbi.1000036")
    citations = query(article)
    puts "#{article.doi.inspect} -> #{article.pub_med.inspect} -> #{article.pub_med_central.inspect} -> #{citations.inspect}"
  end
end
