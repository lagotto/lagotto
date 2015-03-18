# encoding: UTF-8

class ArticleCoverage < Source
  def get_query_url(work)
    return nil unless work.doi =~ /^10.1371/

    url_private % { :doi => work.doi_escaped }
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
    [:url_private]
  end
end
