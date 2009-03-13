class Postgenomic < Source
  include SourceHelper

  def query(article, options={})
    url = "http://www.postgenomic.com/api.php?type=post&format=json&citing_doi=" 

    get_json(url + CGI.escape(article.doi), options).map do |result|
      # Every citation has to have a URI - make one from the URL
      result[:uri] = result.delete("url")
      result
    end
  end

  def public_url_base
    "http://postgenomic.com/paper.php?doi="
  end
end
