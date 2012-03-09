
class TwitterQueueJob

  def queue_new_articles(staleness, days_since_published)
    # staleness in seconds

    source = Source.find_by_name("twitter")

    # determine if the source is active or not
    # determine if the source is disabled or not

    if source.active && (source.disable_until.nil? || source.disable_until < DateTime.now.utc)

      puts "source active"
      Rails.logger.debug "source active"

      # reset the disable_until value
      unless source.disable_until.nil?
        source.disable_until = nil
        source.save
      end

      # TODO once we start returning large dataset from the select statement, we should batch process the data
      # use find_each

      # find articles that need to be updated
      # new articles (from pub date)
      # stale
      # not queued currently
      retrieval_statuses = RetrievalStatus.joins(:article, :source).
          where('sources.id = ?
                 and articles.published_on < ?
                 and articles.published_on > ?
                 and queued_at is NULL
                 and retrieved_at < TIMESTAMPADD(SECOND, -?, UTC_TIMESTAMP())',
                source.id, Time.zone.today, Time.zone.today - days_since_published, staleness).
          readonly(false)

      puts "#{source.name} total article queued #{retrieval_statuses.length}"
      Rails.logger.debug "#{source.name} total article queued #{retrieval_statuses.length}"

      retrieval_statuses.each do | retrieval_status |
        puts "#{source.name} article id #{retrieval_status.article_id}"
        Rails.logger.debug  "#{source.name} article id #{retrieval_status.article_id}"

        article = Article.find(retrieval_status.article_id)

        retrieval_history = RetrievalHistory.new
        retrieval_history.article_id = article.id
        retrieval_history.source_id = source.id
        retrieval_history.save

        Delayed::Job.enqueue TwitterJob.new(article.doi, source, retrieval_status, retrieval_history), :queue => source.name
      end
    end
  end

  # queue up articles
  # need max batch size
  def queue_articles(staleness, batch_size)

    source = Source.find_by_name("twitter")

    puts "#{source.name} queue articles #{DateTime.now}"
    Rails.logger.debug "#{source.name} queue articles #{DateTime.now}"

    # determine if the source is active or not
    # determine if the source is disabled or not

    if source.active && (source.disable_until.nil? || source.disable_until < DateTime.now.utc)

      puts "source active"
      Rails.logger.debug "source active"

      unless source.disable_until.nil?
        source.disable_until = nil
        source.save
      end

      # find articles that need to be updated

      # not queued currently
      # stale from updated_at
      retrieval_statuses = RetrievalStatus.joins(:article, :source).
          where('sources.id = ?
                 and articles.published_on < ?
                 and queued_at is NULL
                 and retrieved_at < TIMESTAMPADD(SECOND, -?, UTC_TIMESTAMP())',
                source.id, Time.zone.today, staleness).
          limit(batch_size).
          readonly(false)

      puts "#{source.name} total article queued #{retrieval_statuses.length}"
      Rails.logger.debug "#{source.name} total article queued #{retrieval_statuses.length}"

      retrieval_statuses.each do | retrieval_status |
        puts "#{source.name} article id #{retrieval_status.article_id}"
        Rails.logger.debug  "#{source.name} article id #{retrieval_status.article_id}"

        article = Article.find(retrieval_status.article_id)

        retrieval_history = RetrievalHistory.new
        retrieval_history.article_id = article.id
        retrieval_history.source_id = source.id
        retrieval_history.save

        Delayed::Job.enqueue TwitterJob.new(article.doi, source, retrieval_status, retrieval_history), :queue => source.name
      end
    end
  end

end
