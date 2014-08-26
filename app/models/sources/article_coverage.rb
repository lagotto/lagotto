# encoding: UTF-8

class ArticleCoverage < Source
  def get_query_url(article)
    return nil unless article.doi =~ /^10.1371/

    url % { :doi => article.doi_escaped }
  end

  def response_options
    { metrics: :comments }
  end

  def get_events(result)
    Array(result['referrals']).map do |item|
      { event: item,
        event_time: get_iso8601_from_time(item['published_on']),
        event_url: item['referral'] }
    end
  end

  def config_fields
    [:url]
  end
end
