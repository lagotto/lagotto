class Bloglines < Source
  include SourceHelper
  def uses_username; true; end
  def uses_password; true; end

  def query(article, options={})
    raise(ArgumentError, "Bloglines configuration requires username & password") \
      if username.blank? or password.blank?

    url = "http://www.bloglines.com/search?format=publicapi&apiuser=#{username}&apikey=#{password}&q=#{CGI.escape(article.title)}"
    get_xml(url, options) do |document|
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
        # Ignore citations of the dx.doi.org URI itself
        citations << citation \
          unless DOI::from_uri(citation[:uri]) == article.doi
      end
      citations
    end
  end
end
