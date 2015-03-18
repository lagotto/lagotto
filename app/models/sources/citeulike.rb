# encoding: UTF-8

class Citeulike < Source
  def request_options
    { content_type: 'xml' }
  end

  def response_options
    { metrics: :shares }
  end

  def get_events(result)
    events = result['posts'] && result['posts']['post'].respond_to?("map") && result['posts']['post']
    events = [events] if events.is_a?(Hash)
    events ||= nil
    Array(events).map do |item|
      { event: item,
        event_time: get_iso8601_from_time(item["post_time"]),
        event_url: item['link']['url'] }
    end
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    "http://www.citeulike.org/api/posts/for/doi/%{doi}"
  end

  def events_url
    "http://www.citeulike.org/doi/%{doi}"
  end

  def rate_limiting
    config.rate_limiting || 2000
  end
end
