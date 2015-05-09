class ArticleCoverage < Source
  # include common methods for Article Coverage
  include Coverable

  def get_extra(result)
    Array(result['referrals']).map do |item|
      { event: item,
        event_time: get_iso8601_from_time(item['published_on']),
        event_url: item['referral'] }
    end
  end
end
