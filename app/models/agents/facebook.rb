class Facebook < Agent
  def get_query_url(options = {})
    fail ArgumentError, "No Facebook access token." unless get_access_token

    work = Work.where(id: options.fetch(:work_id, nil)).first
    return {} unless work.present? && work.get_url

    # use depreciated v2.0 API if url_linkstat is used
    if url_linkstat.present?
      URI.escape(url_linkstat % { access_token: access_token, query_url: work.canonical_url_escaped })
    else
      url % { access_token: access_token, query_url: work.canonical_url_escaped }
    end
  end

  def request_options
    { bearer: access_token }
  end

  def parse_data(result, options={})
    return [result] if result[:error]
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return [{ error: "Resource not found.", status: 404 }] unless work.present?

    result.extend Hashie::Extensions::DeepFetch

    # use depreciated v2.0 API if url_linkstat is used
    # requires user account registerd before August 2014
    if url_linkstat.present?
      total = result.deep_fetch('data', 0, 'total_count') { 0 }
    else
      total = result.deep_fetch('share', 'share_count') { 0 }
    end

    # don't trust results if event count is above preset limit
    # workaround for Facebook getting confused about the canonical URL
    if total > count_limit.to_i
      readers, comments, likes, total = 0, 0, 0, 0
    elsif url_linkstat.blank?
      readers, comments, likes = 0, 0, 0
    else
      readers = result.deep_fetch('data', 0, 'share_count') { 0 }
      comments = result.deep_fetch('data', 0, 'comment_count') { 0 }
      likes = result.deep_fetch('data', 0, 'like_count') { 0 }
    end

    relations = []
    if url_linkstat.blank? && total > 0
      relations << { relation: { "subj_id" => work.pid,
                                 "obj_id" => "https://facebook.com/",
                                 "relation_type_id" => "is_referenced_by",
                                 "total" => total,
                                 "source_id" => source_id },
                     obj: { "pid" => "https://facebook.com/",
                            "URL" => "https://facebook.com/",
                            "title" => "Facebook",
                            "issued" => { "date-parts" => [[2008, 2, 8]] }} }
    end

    if readers > 0
      relations << { relation: { "subj_id" => work.pid,
                                 "obj_id" => "https://facebook.com/",
                                 "relation_type_id" => "is_bookmarked_by",
                                 "total" => readers,
                                 "source_id" => source_id },
                     obj: { "pid" => "https://facebook.com/",
                            "URL" => "https://facebook.com/",
                            "title" => "Facebook",
                            "issued" => { "date-parts" => [[2008, 2, 8]] }} }
    end

    if comments > 0
      relations << { relation: { "subj_id" => work.pid,
                                 "obj_id" => "https://facebook.com/",
                                 "relation_type_id" => "is_discussed_by",
                                 "total" => comments,
                                 "source_id" => source_id },
                     obj: { "pid" => "https://facebook.com/",
                            "URL" => "https://facebook.com/",
                            "title" => "Facebook",
                            "issued" => { "date-parts" => [[2008, 2, 8]] }} }
    end

    if likes > 0
      relations << { relation: { "subj_id" => work.pid,
                                 "obj_id" => "https://facebook.com/",
                                 "relation_type_id" => "is_liked_by",
                                 "total" => likes,
                                 "source_id" => source_id },
                     obj: { "pid" => "https://facebook.com/",
                            "URL" => "https://facebook.com/",
                            "title" => "Facebook",
                            "issued" => { "date-parts" => [[2008, 2, 8]] }} }
    end

    relations
  end

  def get_access_token(options={})
    # Check whether we already have an access token
    return true if access_token.present?

    # Otherwise get new access token
    result = get_result(get_authentication_url, options.merge(agent_id: id))

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
    [:url, :url_linkstat, :authentication_url, :client_id, :client_secret, :access_token, :count_limit]
  end

  def authentication_url
    "https://graph.facebook.com/oauth/access_token?client_id=%{client_id}&client_secret=%{client_secret}&grant_type=client_credentials"
  end

  def url
    "https://graph.facebook.com/v2.1/?access_token=%{access_token}&id=%{query_url}"
  end

  # use depreciated v2.0 API if url_linkstat is used
  # requires user account registerd before August 2014
  # https://graph.facebook.com/fql?access_token=%{access_token}&q=select url, share_count, like_count, comment_count, click_count, total_count from link_stat where url = '%{query_url}'
  def url_linkstat
    config.url_linkstat
  end

  def url_linkstat=(value)
    config.url_linkstat = value
  end

  def cron_line
    config.cron_line || "* 6,18 * * *"
  end
end
