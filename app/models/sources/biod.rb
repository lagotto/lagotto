
class Biod < Source

  SOURCE_URL = 'http://www.plosreports.org/services/rest?method=usage.stats&journal=biod&doi='

  def get_data(article)

    query_url = "#{SOURCE_URL}#{CGI.escape(article.doi)}"

    options = {}
    options[:timeout] = timeout

    get_xml(query_url, options) do |document|
      views = []
      event_count = 0
      document.find("//rest/response/results/item").each do | view |

        month = view.find_first("month")
        year = view.find_first("year")
        month = view.find_first("month")
        html = view.find_first("get-document")
        xml = view.find_first("get-xml")
        pdf = view.find_first("get-pdf")

        curMonth = {}
        curMonth[:month] = month.content
        curMonth[:year] = year.content

        if pdf
          curMonth[:pdf_views] = pdf.content
          event_count += pdf.content.to_i
        else
          curMonth[:pdf_views] = 0
        end

        if xml
          curMonth[:xml_views] = xml.content
          event_count += xml.content.to_i
        else
          curMonth[:xml_views] = 0
        end

        if html
          curMonth[:html_views] = html.content
          event_count += html.content.to_i
        else
          curMonth[:html_views] = 0
        end

        views << curMonth
      end

      events = []

      if(views.size > 0)
        event = {}
        event[:uri] = query_url
        event[:views] = views;

        events << event
      end

      {:events => events, :event_count => event_count}
    end

  end

  def queue_jobs
    # this job should be scheduled to run once a day

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