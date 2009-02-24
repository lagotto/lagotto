class Connotea < Source
  include SourceHelper
  def uses_username; true; end
  def uses_password; true; end

  def query(article)
    raise(ArgumentError, "Connotea configuration requires username & password") \
      if username.blank? or password.blank?

    url = "http://www.connotea.org/data/uri/#{DOI::to_url article.doi}"
    get_xml(url, :username => username, :password => password) do |document|
      citations = []
      document.root.namespaces.default_prefix = 'default'
      document.find("//default:Post").each do |cite|
        citations << { :uri => cite.find_first("@rdf:about").value }
      end
      citations
    end
  end
end
