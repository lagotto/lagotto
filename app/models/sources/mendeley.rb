
class Mendeley < Source

  validates_each :api_key do |record, attr, value|
    record.errors.add(attr, "can't be blank") if value.blank?
  end

  def get_data(article, options={})
    raise(ArgumentError, "#{display_name} configuration requires api key") \
      if config.api_key.blank?

    result = []

    # try mendeley id first if we have it
    if !options[:retrieval_status].local_id.nil?
      result = get_json_data(search_url(options[:retrieval_status].local_id), options)
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

      url = result['mendeley_url']

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

      {:events => result,
       :events_url => url,
       :event_count => total,
       :local_id => result['uuid']}
    end

  end

  def search_url(id, id_type = nil)
    if id_type.nil?
      "http://api.mendeley.com/oapi/documents/details/#{id}/?consumer_key=#{config.api_key}"
    else
      "http://api.mendeley.com/oapi/documents/details/#{id}/?type=#{id_type}&consumer_key=#{config.api_key}"
    end
  end

  def related_url(uuid)
    "http://api.mendeley.com/oapi/documents/related/#{uuid}/?consumer_key=#{config.api_key}"
  end

  def get_json_data(url, options={})
    begin
      result = get_json(url, options)
    rescue => e
      Rails.logger.error("#{display_name} #{e.message}")
      if e.respond_to?('response')
        if e.response.kind_of?(Net::HTTPForbidden)
          # http response 403
          Rails.logger.error "Mendeley returned 403, they might be throttling us."
        end
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

  def get_config_fields
    [{:field_name => "api_key", :field_type => "text_field"}]
  end

  def api_key
    config.api_key
  end

  def api_key=(value)
    config.api_key = value
  end
end