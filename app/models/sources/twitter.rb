
class Twitter < Source

  def get_data(article, options={})
    raise(ArgumentError, "#{display_name} configuration requires a url") \
      if config.url.blank?

    query_url = "#{config.url}#{CGI.escape("\"#{article.doi}\"")}"

    events = []

    json_data = get_json(query_url, options)

    if json_data.length > 0
      results = json_data["rows"]

      results.each do | result |
        tweet = result["value"]

        username = tweet["from_user"]

        if username.nil?
          username = tweet["user"]["screen_name"]
        end

        tweet[:url] = "http://twitter.com/#!/#{username}/status/#{tweet["id_str"]}"
        # this information is couchdb specific, remove it
        tweet.delete("_id")
        tweet.delete("_rev")

        events << tweet
      end
    end

    {:events => events, :event_count => events.length}
  end


  def queue_new_articles

    # get the source specific configurations
    source_config = YAML.load_file("#{Rails.root}/config/source_configs.yml")[Rails.env]
    source_config = source_config[name]

    # get job specific configuration
    if !source_config.has_key?('new_articles')
      # TODO let someone know that the source isn't configured correctly
      Rails.logger.error "#{display_name}: new_articles configuration is missing"
      return
    end

    source_config = source_config['new_articles']
    if !source_config.has_key?('batch_time_interval') || !source_config.has_key?('days_since_published')
      # TODO let someone know that the source isn't configured correctly
      Rails.logger.error "#{display_name}: batch_time_interval is missing or days_since_published is missing"
      return
    end

    source_config['batch_time_interval'] = parse_time_config(source_config['batch_time_interval'])

    # determine if the source is active
    if self.active
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
        queue_new_article_jobs(source_config)
      end
    end

    return source_config['batch_time_interval']
  end

  def queue_new_article_jobs(source_config)

    # find articles that need to be updated
    retrieval_statuses = RetrievalStatus.joins(:article, :source).
        where('sources.id = ?
               and articles.published_on < ?
               and articles.published_on > ?
               and queued_at is NULL',
              id, Time.zone.today, Time.zone.today - source_config['days_since_published']).
        readonly(false)

    Rails.logger.debug "#{name}: total article queued #{retrieval_statuses.length}"

    retrieval_statuses.each do | retrieval_status |

      retrieval_history = RetrievalHistory.new
      retrieval_history.article_id = retrieval_status.article_id
      retrieval_history.source_id = id
      retrieval_history.save

      Delayed::Job.enqueue SourceJob.new(retrieval_status.article_id, self, retrieval_status, retrieval_history), :queue => name
    end
  end

end