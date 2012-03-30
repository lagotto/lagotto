
class Postgenomic < Source

  def get_data(article, options={})
    url = "http://www.postgenomic.com/api.php?type=post&format=json&citing_doi="

    events = get_json(url + CGI.escape(article.doi), options).map do |result|
      {:event => result, :event_url => result["url"]}
    end

    {:events => events,
     :events_url => "http://postgenomic.com/paper.php?doi=#{CGI.escape(article.doi)}",
     :event_count => events.length}

  end
end