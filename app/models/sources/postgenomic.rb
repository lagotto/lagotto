
class Postgenomic < Source
  include SourceHelper

  def uses_url; true; end

  def query(article)
    raise(ArgumentError, "Postgenomic configuration requires URL") \
      if url.blank?

    get_json(url + CGI.escape(article.doi)).map do |result|
      # Every citation has to have a URI - make one from the URL
      result[:uri] = result.delete("url")
      result
    end
  end
end
