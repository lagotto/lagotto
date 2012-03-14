require 'cgi'

class Twitter < Source

  SOURCE_URL = "http://tws-mia.plos.org:5984/plos-tweetstream/_design/tweets/_view/by_doi?key="

  def get_data(doi)
    query_url = "#{SOURCE_URL}#{CGI.escape("\"#{doi}\"")}"

    puts "#{query_url}"

    options = {}
    events = []

    options[:timeout] = timeout

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

    [events, events.length]
  end

  def queue_jobs

    # get the source specific configurations
    source_config = get_source_config(self.name)

    # get job specific configuration
    if !source_config.has_key?('queue_jobs')
      # TODO let someone know that the source isn't configured correctly
      puts "queue_jobs is missing"
      return
    end

    source_config = source_config['queue_jobs']
    if !source_config.has_key?('batch_time_interval') || !source_config.has_key?('staleness')
      # TODO let someone know that the source isn't configured correctly
      puts "batch_time_interval is missing or staleness is missing"
      return
    end
    # batch_time_interval should be in seconds
    # staleness should be in seconds

    # determine if the source is active
    if self.active
      puts "source is active"
      queue_job = true

      # determine if the source is disabled or not
      unless self.disable_until.nil?
        queue_job = false

        if self.disable_until < Time.now.utc
          self.disable_until = nil
          self.save
          queue_job = true
        elsif self.disable_until < (Time.now.utc + source_config['batch_time_interval'])
          # the source will become not disabled before the next round (of job queueing)
          # just sleep til the source will become not disabled and queue the jobs
          source_config['batch_time_interval'] = Time.now.utc - self.disable_until
        end
      end

      if queue_job
        queue_jobs_helper(source_config)
      end
    end

    return source_config['batch_time_interval']
  end

  def queue_jobs_helper(options)

    if !options.has_key?('staleness')
      Rails.logger.info "Staleness value was not passed in.  Existing"
      return
    end

    # find articles that need to be updated

    # not queued currently
    # stale from updated_at
    retrieval_statuses = RetrievalStatus.joins(:article, :source).
        where('sources.id = ?
               and articles.published_on < ?
               and queued_at is NULL
               and retrieved_at < TIMESTAMPADD(SECOND, -?, UTC_TIMESTAMP())',
              id, Time.zone.today, options['staleness']).
        readonly(false).limit(10)

    puts "#{name} total article queued #{retrieval_statuses.length}"
    Rails.logger.debug "#{name} total article queued #{retrieval_statuses.length}"

    retrieval_statuses.each do | retrieval_status |
      puts "#{name} article id #{retrieval_status.article_id}"
      Rails.logger.debug  "#{name} article id #{retrieval_status.article_id}"

      article = Article.find(retrieval_status.article_id)

      retrieval_history = RetrievalHistory.new
      retrieval_history.article_id = article.id
      retrieval_history.source_id = id
      retrieval_history.save

      Delayed::Job.enqueue SourceJob.new(article.doi, self, retrieval_status, retrieval_history), :queue => name
    end
  end


  def queue_new_article_jobs

    # get the source specific configurations
    source_config = get_source_config(name)

    # get job specific configuration
    if !source_config.has_key?('queue_new_article_jobs')
      # TODO let someone know that the source isn't configured correctly
      puts "queue_new_article_jobs is missing"
      return
    end

    source_config = source_config['queue_new_article_jobs']
    if !source_config.has_key?('batch_time_interval') || !source_config.has_key?('days_since_published')
      # TODO let someone know that the source isn't configured correctly
      puts "batch_time_interval is missing or days_since_published is missing"
      return
    end

    # determine if the source is active
    if self.active
      puts "source is active"
      queue_job = true

      # determine if the source is disabled or not
      unless self.disable_until.nil?
        queue_job = false

        if self.disable_until < Time.now.utc
          self.disable_until = nil
          self.save
          queue_job = true
        elsif self.disable_until < (Time.now.utc + source_config['batch_time_interval'])
          # the source will become not disabled before the next round (of job queueing)
          # just sleep til the source will become not disabled and queue the jobs
          source_config['batch_time_interval'] = Time.now.utc - self.disable_until
        end
      end

      if queue_job
        queue_new_article_jobs_helper(source_config)
      end
    end

    return source_config['batch_time_interval']
  end

  def queue_new_article_jobs_helper(options)

    if !options.has_key?('days_since_published')
      Rails.logger.info "days_since_published value was not passed in.  Existing"
      return
    end

    # find articles that need to be updated
    retrieval_statuses = RetrievalStatus.joins(:article, :source).
        where('sources.id = ?
               and articles.published_on < ?
               and articles.published_on > ?
               and queued_at is NULL',
              id, Time.zone.today, Time.zone.today - options['days_since_published']).
        readonly(false).limit(1)

    puts "#{name} total article queued #{retrieval_statuses.length}"
    Rails.logger.debug "#{name} total article queued #{retrieval_statuses.length}"

    retrieval_statuses.each do | retrieval_status |

      puts "#{name} article id #{retrieval_status.article_id}"
      Rails.logger.debug  "#{name} article id #{retrieval_status.article_id}"

      article = Article.find(retrieval_status.article_id)

      retrieval_history = RetrievalHistory.new
      retrieval_history.article_id = article.id
      retrieval_history.source_id = id
      retrieval_history.save

      Delayed::Job.enqueue SourceJob.new(article.doi, self, retrieval_status, retrieval_history), :queue => name
    end
  end

end