class Nature < Source
  include SourceHelper

  def query(article, options={})
    url = "http://blogs.nature.com/posts.json?doi="
    query_url = url + CGI.escape(article.doi)
    results = get_json(query_url, options)
    citations = results.map do |result|
      # The body's huge - don't bother saving it.
      result["post"].delete("body")

      # Every citation has to have a URI - make one from the URL, 
      # which probably doesn't begin with "http://" (ugh).
      uri = result["post"].delete("url")
      uri = "http://#{uri}" unless uri.start_with?("http://")
      result[:uri] = uri

      result
    end
    citations
  end

  def public_url_base
    "http://blogs.nature.com/posts?doi="
  end
end
