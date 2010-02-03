class Connotea < Source
  include SourceHelper
  include Log
  
  def uses_username; true; end
  def uses_password; true; end
  def uses_search_url; true; end

  def query(article, options={})
    raise(ArgumentError, "Connotea configuration requires username & password") \
      if username.blank? or password.blank?

    url = "http://www.connotea.org/data/uri/#{DOI::to_url article.doi}"
    
    log_info("Connotea query: #{url}")
    
    get_xml(url, options.merge(:username => username, :password => password))\
        do |document|
      citations = []
      document.root.namespaces.default_prefix = 'default'
      document.find("//default:Post").each do |cite|
        uri = cite.find_first("@rdf:about").value
        citations << { :uri => uri }

        # Note CiteULike's internal ID if we haven't already
        options[:retrieval].local_id ||= uri[uri.rindex('/')+1..-1]
      end
      citations
    end
  end

  def public_url(retrieval)
    retrieval.local_id && ("http://www.connotea.org/uri/" + retrieval.local_id)
  end
end
