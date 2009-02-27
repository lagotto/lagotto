class Citeulike < Source
  include SourceHelper

  def query(article, options={})
    url = "http://www.citeulike.org/api/posts/for/doi/#{CGI.escape(article.doi)}"
    get_xml(url, options) do |document|
      citations = []
      document.find("//posts/post").each do |cite|
        link = cite.find_first("link")
        post_time = cite.find_first("post_time")
        tags = []
        cite.find("tag").each do |tag|
          tags << tag.content
        end

        citation = {}
        citation[:username] = cite.attributes['username']
        citation[:articleid] = cite.attributes['article_id']
        citation[:post_time] = post_time.content
        citation[:tags] = tags.join ', ' 
        citation[:uri] = link.attributes['url']
	
        citations << citation
      end
      citations
    end
  end
end

