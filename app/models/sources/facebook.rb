class Facebook < Source
  def get_query_url(work, options = {})
    fail ArgumentError, "No Facebook access token." unless get_access_token
    return {} unless work.get_url
      url % { access_token: access_token, query_url: work.canonical_url_escaped }
  end

  def request_options
    { bearer: access_token }
  end

  def parse_data(result, work, options={})
    return result if result[:error]

    result.extend Hashie::Extensions::DeepFetch
      total = result.deep_fetch('share', 'share_count') { 0 }
 
    if total > count_limit.to_i
      readers, comments, likes, total = 0, 0, 0, 0
      extra = {}
    else
      readers = result.deep_fetch('share', 'share_count') { 0 }
      comments = result.deep_fetch('share', 0, 'comment_count') { 0 }
      likes = result.deep_fetch('share', 0, 'like_count') { 0 }
      url = result['id']
      # Need clarification on what to use for getting facebook likes from the graph api
      extra = {
               "comment_count" => comments, 
               "share_count" =>  readers, 
               "like_count" => likes,
               "url" => url,
               "total_count" => total
      } || {}
    end

    { events: {
        source: name,
        work: work.pid,
        readers: readers,
        comments: comments,
        likes: likes,
        total: total,
        extra: extra } }
  end

  def get_access_token(options={})
    # Check whether we already have an access token
    return true if access_token.present?

    # Otherwise get new access token
    result = get_result(get_authentication_url, options.merge(source_id: id))

    if result && result.is_a?(String)
      # response is in format "access_token=12345"
      # or a hash if an error occured
      config.access_token = result.rstrip[13..-1]
      save
    else
      false
    end
  end

  def get_authentication_url
    authentication_url % { client_id: client_id, client_secret: client_secret }
  end

  def config_fields
    [:url, :authentication_url, :client_id, :client_secret, :access_token, :count_limit]
  end

  def authentication_url
    "https://graph.facebook.com/oauth/access_token?client_id=%{client_id}&client_secret=%{client_secret}&grant_type=client_credentials"
  end

  def url
    "https://graph.facebook.com/v2.7/?access_token=%{access_token}&id=%{query_url}"
  end
  
end
