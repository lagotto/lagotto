
class Pmc < Source

  def uses_url; true; end

  def get_data(article)
    raise(ArgumentError, "#{display_name} requires url") \
      if url.blank?

    query_url = "#{url}#{CGI.escape(article.doi)}"

    events = nil
    event_count = nil
    results = []

    options = {}
    options[:timeout] = timeout

    begin
      results = get_json(query_url, options)
    rescue => e
      if e.respond_to?('response')
        # 404 is a valid response from the pmc usage stat source if the data doesn't exist for the given article
        unless e.response.kind_of?(Net::HTTPNotFound)
          raise e
        end
      else
        raise e
      end
    end

    if results.length > 0
      events = results["views"]

      # the event count will be the sum of all the full-text values and pdf values
      unless events.nil?
        event_count = 0
        events.each do | event |
          event_count += event['full-text'].to_i + event['pdf'].to_i
        end
      end
    end

    {:events => events, :event_count => event_count}
  end

end