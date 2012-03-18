
class Pmc < Source

  def uses_url; true; end

  def get_data(article)
    raise(ArgumentError, "#{display_name} requires url") \
      if url.blank?

    query_url = "#{url}#{CGI.escape(article.doi)}"

    events = nil
    event_count = nil
    results = []

    options = {}
    options[:timeout] = timeout

    begin
      results = get_json(query_url, options)
    rescue => e
      if e.respond_to?('response')
        # 404 is a valid response from the pmc usage stat source if the data doesn't exist for the given article
        unless e.response.kind_of?(Net::HTTPNotFound)
          raise e
        end
      else
        raise e
      end
    end

    if results.length > 0
      events = results["views"]

      # the event count will be the sum of all the full-text values and pdf values
      unless events.nil?
        event_count = 0
        events.each do | event |
          event_count += event['full-text'].to_i + event['pdf'].to_i
        end
      end
    end

    {:events => events, :event_count => event_count}
  end

  def queue_jobs
    # this job will be scheduled to run once a month.
    # that's how often we get the information from PMC

    # determine if the source is active
    if active && (disable_until.nil? || disable_until < Time.now.utc)

      # reset disable_until value
      unless self.disable_until.nil?
        self.disable_until = nil
        save
      end

      queue_jobs_helper
    else
      Rails.logger.error "#{name} is either inactive or is disabled."
      raise "#{display_name} (#{name}) is either inactive or is disabled"
    end
  end

  def queue_jobs_helper

    # grab all the articles
    retrieval_statuses = RetrievalStatus.joins(:article, :source).
        where('sources.id = ?
               and articles.published_on < ?
               and queued_at is NULL',
              id, Time.zone.today).
        readonly(false)

    retrieval_statuses.find_each do | retrieval_status |

      retrieval_history = RetrievalHistory.new
      retrieval_history.article_id = retrieval_status.article_id
      retrieval_history.source_id = id
      retrieval_history.save

      Delayed::Job.enqueue SourceJob.new(retrieval_status.article_id, self, retrieval_status, retrieval_history), :queue => name
    end
  end

end