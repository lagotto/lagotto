
class Mendeley < Source

  def get_data(article)
    raise(ArgumentError, "#{display_name} configuration requires api key") \
      if api_key.blank?

    options = {}
    options[:timeout] = timeout

    result = []

    # try mendeley id first if we have it
    # there should be only one
    rs = RetrievalStatus.where(:article_id => article.id, :source_id => id).first
    if !rs.local_id.nil?
      result = get_json_data(search_url(rs.local_id), options)
    end

    # try using doi
    if result.length == 0
      # doi has to be double encoded.
      result = get_json_data(search_url(CGI.escape(CGI.escape(article.doi)), "doi"), options)
    end

    # querying by doi sometimes fails
    # try pub med id
    if result.length == 0 && !article.pub_med.nil?
      result = get_json_data(search_url(article.pub_med, "pmid"), options)
    end

    if result.length > 0

      uri = result['mendeley_url']
      result['uri'] = uri

      # event count is the reader number and group number combined
      total = 0
      readers = result['stats']['readers']
      unless readers.nil?
        total += readers
      end

      groups = result['groups']
      unless groups.nil?
        total += groups.length
      end

      related_articles = get_json_data(related_url(result['uuid']), options)
      if related_articles.length > 0
        result[:related] = related_articles['documents']
      end

      {:events => result, :event_count => total, :local_id => result['uuid']}
    end

  end

  def search_url(id, id_type = nil)
    if id_type.nil?
      "http://api.mendeley.com/oapi/documents/details/#{id}/?consumer_key=#{api_key}"
    else
      "http://api.mendeley.com/oapi/documents/details/#{id}/?type=#{id_type}&consumer_key=#{api_key}"
    end
  end

  def related_url(uuid)
    "http://api.mendeley.com/oapi/documents/related/#{uuid}/?consumer_key=#{api_key}"
  end

  def get_json_data(url, options={})
    begin
      result = get_json(url, options)
    rescue => e
      Rails.logger.error("#{display_name} #{e.message}")
      if e.respond_to?('response')
        # if the article could not be found by the Mendeley api, continue on (we will get a 404 error)
        # if we get any other error, throw it so it can be handled by the caller (ex. 503)
        unless e.response.kind_of?(Net::HTTPNotFound)
          raise e
        end
      else
        raise e
      end
    end
  end

end