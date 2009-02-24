class Bloglines < Source
  include SourceHelper
  def uses_username; true; end
  def uses_password; true; end

  def query(article)
    raise(ArgumentError, "Bloglines configuration requires username & password") \
      if username.blank? or password.blank?

    url = "http://www.bloglines.com/search?format=publicapi&apiuser=#{username}&apikey=#{password}&q=#{CGI.escape(article.doi)}"
    get_xml(url) do |document|
      citations = []
      document.find("//resultset/result").each do |cite|
        citation = {}
        %w[site/name site/url site/feedurl title author abstract url].each do |a|
          first = cite.find_first("#{a}")
          if first
            citation[a.gsub('/','_').intern] = first.content
          end
        end
        citation[:uri] = citation.delete(:url)
        citations << citation unless DOI::from_uri(citation[:uri]) == doi
      end
      citations
    end
  end
end
