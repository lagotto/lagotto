
class Citeulike < Source

  SOURCE_URL = 'http://www.citeulike.org/api/posts/for/doi/'

  def get_data(article)

    url = "#{SOURCE_URL}#{CGI.escape(article.doi)}"

    options = {}
    options[:timeout] = timeout

    get_xml(url, options) do |document|
      citations = []
      local_ids = {}

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

        # Note CiteULike's internal ID if we haven't already
        # there can be multiple internal IDs for an article
        local_ids[citation[:articleid]] = citation[:articleid]
      end

      xml_string = document.to_s(:encoding => XML::Encoding::UTF_8)

      {:events => citations,
       :event_count => citations.length,
       :local_id => local_ids.values.join(","),
       :attachment => {:filename => "events.xml", :content_type => "text\/xml", :data => xml_string }
      }
    end
  end

end