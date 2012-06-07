
class Nature < Source
  SECONDS_IN_A_DAY = 86400
  BATCH_SIZE = 1000

  validates_each :url, :api_key do |record, attr, value|
    record.errors.add(attr, "can't be blank") if value.blank?
  end

  def get_data(article, options={})
    raise(ArgumentError, "#{display_name} configuration requires an api key") \
      if config.api_key.blank?

    query_url = get_query_url(article)

    begin
      results = get_json(query_url, options)
    rescue => e
      Rails.logger.error("#{display_name} #{e.message}")
      if e.respond_to?('response')
        if e.response.kind_of?(Net::HTTPForbidden)
          # http response 403
          Rails.logger.error "#{display_name} returned 403, they might be throttling us."
        end
      end
      raise e
    end

    events = results.map do |result|
      url = result['post']['url']
      url = "http://#{url}" unless url.start_with?("http://")

      {:event => result['post'], :event_url => url}
    end

    {:events => events, :event_count => events.length}
  end

  def queue_articles

    # get the source specific configurations
    source_config = YAML.load_file("#{Rails.root}/config/source_configs.yml")[Rails.env]
    source_config = source_config[name]

    # get job specific configuration
    if !source_config.has_key?('requests_per_day')
      Rails.logger.error "#{display_name}: requests_per_day is missing"
      raise "#{display_name}: requests_per_day is missing"
      return
    end

    # assumptions
    # requests per day is smaller than the total number of articles in the application
    # requests per day is smaller than total number of seconds in 1 day

    total_requests = source_config['requests_per_day']
    source_config['batch_time_interval'] = SECONDS_IN_A_DAY
    source_config['seconds_between_request'] = SECONDS_IN_A_DAY / total_requests

    # determine if the source is active
    if active
      queue_job = true

      # determine if the source is disabled or not
      unless self.disable_until.nil?
        queue_job = false

        if self.disable_until < Time.now.utc
          self.disable_until = nil
          save
          queue_job = true
        end
      end

      if queue_job
        queue_article_jobs(source_config)
      end
    end

    return source_config['batch_time_interval']
  end

  def queue_article_jobs(source_config)
    # figure out when the next job should be scheduled
    job = Delayed::Job.where("queue = 'nature'").select('run_at').order('run_at DESC').limit(1)
    run_at = Time.zone.now
    if job.length > 0
      run_at = job[0].run_at
    end

    limit = BATCH_SIZE
    offset = 0

    while offset < source_config['requests_per_day']
      # find articles that need to be updated
      # not queued currently
      # stale from updated_at
      retrieval_statuses = RetrievalStatus.joins(:article, :source).
          where('sources.id = ?
             and articles.published_on < ?
             and queued_at is NULL',
                id, Time.zone.today).
          order('retrieved_at DESC').
          limit(limit).
          offset(offset).
          select("retrieval_statuses.id")

      Rails.logger.debug "#{name} total article queued #{retrieval_statuses.length}"

      retrieval_statuses.each do | retrieval_status |

        run_at += source_config['seconds_between_request']

        Delayed::Job.enqueue SourceJob.new([retrieval_status], id), :queue => name, :run_at => run_at
      end

      offset += limit
    end
  end

  def get_query_url(article)
    config.url % { :api_key => config.api_key, :doi => CGI.escape(article.doi) }
  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"},
     {:field_name => "api_key", :field_type => "text_field"}]
  end

  def url
    config.url
  end

  def url=(value)
    config.url = value
  end

  def api_key
    config.api_key
  end

  def api_key=(value)
    config.api_key = value
  end
end