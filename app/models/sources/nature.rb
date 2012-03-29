
class Nature < Source
  SECONDS_IN_A_DAY = 86400
  BATCH_SIZE = 1000

  def get_data(article, options={})
    raise(ArgumentError, "#{display_name} configuration requires an api key") \
      if config.api_key.blank?

    query_url = "http://api.nature.com/service/blogs/posts.json?api_key=#{config.api_key}&doi=#{CGI.escape(article.doi)}"

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
      # TODO let someone know that the source isn't configured correctly
      Rails.logger.error "#{display_name}: requests_per_day is missing"
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
        elsif self.disable_until < (Time.now.utc + source_config['batch_time_interval'])
          # the source will become not disabled before the next round (of job queueing)
          # just sleep til the source will become not disabled and queue the jobs
          source_config['batch_time_interval'] = Time.now.utc - self.disable_until
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
          readonly(false)

      Rails.logger.debug "#{name} total article queued #{retrieval_statuses.length}"

      retrieval_statuses.each do | retrieval_status |

        retrieval_history = RetrievalHistory.new
        retrieval_history.article_id = retrieval_status.article_id
        retrieval_history.source_id = id
        retrieval_history.save

        run_at += source_config['seconds_between_request']

        Delayed::Job.enqueue SourceJob.new(retrieval_status.article_id, self, retrieval_status, retrieval_history),
                             :queue => name,
                             :run_at => run_at
      end

      offset += limit
    end
  end

end