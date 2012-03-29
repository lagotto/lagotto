
class Citeulike < Source

  SOURCE_URL = 'http://www.citeulike.org/api/posts/for/doi/'

  def get_data(article, options={})

    url = "#{SOURCE_URL}#{CGI.escape(article.doi)}"

    get_xml(url, options) do |document|
      events = []
      local_ids = {}

      document.find("//posts/post").each do |post|
        post_string = post.to_s(:encoding => XML::Encoding::UTF_8)
        event = Hash.from_xml(post_string)
        event = event['post']
        events << {:event => event, :event_url => event['link']['url']}

        # Note CiteULike's internal ID if we haven't already
        # there can be multiple internal IDs for an article
        local_ids[event['article_id']] = event['article_id']
      end

      events_url = local_ids.values.map {|article_id| "http://www.citeulike.org/article-posts/#{article_id}"}

      xml_string = document.to_s(:encoding => XML::Encoding::UTF_8)

      {:events => events,
       :events_url => events_url,
       :event_count => events.length,
       :attachment => {:filename => "events.xml", :content_type => "text\/xml", :data => xml_string }
      }
    end
  end

end