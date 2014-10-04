# encoding: UTF-8

class Facebook < Source
  def get_query_url(article, options={})
    return nil unless article.get_url

    URI.escape(url % { access_token: access_token, query_url: article.canonical_url_escaped })
  end

  def parse_data(result, article, options={})
    return result if result[:error]

    result.extend Hashie::Extensions::DeepFetch

    # don't trust results if event count is above preset limit
    # workaround for Facebook getting confused about the canonical URL
    total = result.deep_fetch('data', 0, 'total_count') { 0 }
    if total > count_limit.to_i
      shares, comments, likes, total = 0, 0, 0, 0
    else
      shares = result.deep_fetch('data', 0, 'share_count') { 0 }
      comments = result.deep_fetch('data', 0, 'comment_count') { 0 }
      likes = result.deep_fetch('data', 0, 'like_count') { 0 }
    end

    events = result['data'] || {}

    { events: events,
      events_by_day: [],
      events_by_month: [],
      events_url: nil,
      event_count: total,
      event_metrics: get_event_metrics(shares: shares, comments: comments, likes: likes, total: total) }
  end

  def config_fields
    [:url, :access_token, :count_limit]
  end

  def url
    config.url || "https://graph.facebook.com/fql?access_token=%{access_token}&q=select url, share_count, like_count, comment_count, click_count, total_count from link_stat where url = '%{query_url}'"
  end
end
