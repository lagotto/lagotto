# encoding: UTF-8

class Facebook < Source
  def get_query_url(article, options={})
    return nil unless get_access_token && article.get_url

    # use depreciated v2.0 API if linkstat_url is used
    if linkstat_url.present?
      URI.escape(url % { access_token: access_token, query_url: article.canonical_url_escaped })
    else
      url % { access_token: access_token, query_url: article.canonical_url_escaped }
    end
  end

  def parse_data(result, article, options={})
    return result if result[:error]

    result.extend Hashie::Extensions::DeepFetch

    # use depreciated v2.0 API if linkstat_url is used
    # requires user account registerd before August 2014
    if linkstat_url.present?
      total = result.deep_fetch('data', 0, 'total_count') { 0 }
    else
      total = result.deep_fetch('share', 'share_count') { 0 }
    end

    # don't trust results if event count is above preset limit
    # workaround for Facebook getting confused about the canonical URL
    if total > count_limit.to_i
      shares, comments, likes, total = 0, 0, 0, 0
    elsif linkstat_url.blank?
      shares, comments, likes = 0, 0, 0
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

  def get_access_token(options={})
    # Check whether we already have an access token
    return true if access_token.present?

    # Otherwise get new access token
    result = get_result(authentication_url, options.merge(
      content_type: 'html',
      client_id: app_id,
      client_secret: app_secret,
      grant_type: "client_credentials",
      source_id: id))

    if result
      # response is in format "access_token=12345"
      config.access_token = result.rstrip[13..-1]
      save
    else
      false
    end
  end

  def config_fields
    [:url, :linkstat_url, :authentication_url, :app_id, :app_secret, :access_token, :count_limit]
  end

  def authentication_url
    config.authentication_url || "https://graph.facebook.com/oauth/access_token?"
  end

  def url
    config.url || "https://graph.facebook.com/v2.1/?access_token=%{access_token}&id=%{query_url}"
  end

  # use depreciated v2.0 API if linkstat_url is used
  # requires user account registerd before August 2014
  # https://graph.facebook.com/fql?access_token=%{access_token}&q=select url, share_count, like_count, comment_count, click_count, total_count from link_stat where url = '%{query_url}'
  def linkstat_url
    config.linkstat_url
  end

  def linkstat_url=(value)
    config.linkstat_url = value
  end
end
