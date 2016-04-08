class Pmc < Agent
  def get_query_url(options={})
    # check that we have publisher-specific configuration
    pc = publisher_config(options[:publisher_id])
    return nil if pc.username.nil? || pc.password.nil?

    year = options[:year]
    month = options[:month]
    journal = options[:journal]

    url % { year: year, month: month, journal: journal, username: pc.username, password: pc.password }
  end

  def request_options
    { content_type: 'xml' }
  end

  # number of xml files to fetch: publishers * journals * months
  def get_total(options={})
    options[:months] ||= 1
    publisher_configs.reduce(0) do |sum, publisher|
      publisher_id = publisher[0]
      sum += publisher[1].journals.to_s.split(" ").count * options[:months]
    end
  end

  def queue_jobs(options={})
    return 0 unless active?

    unless options[:all]
      return 0 unless stale?
    end

    from_date = options[:from_date].present? ? Date.parse(options[:from_date]) : Time.zone.now.to_date
    dates = date_range(year: from_date.year, month: from_date.month)

    total = get_total(months: dates.length)

    if total > 0
      publisher_configs.each do |publisher|
        options[:publisher_id] = publisher[0]

        journals = publisher[1].journals.to_s.split(" ")
        journals.each do |journal|
          options[:journal] = journal

          dates.each do |date|
            options[:month] = date[:month]
            options[:year] = date[:year]

            AgentJob.set(queue: queue, wait_until: schedule_at).perform_later(self, options)
          end
        end
      end

      schedule_next_run
    end

    # return number of works queued
    total
  end

  def get_data(options={})
    query_url = get_query_url(options)
    get_result(query_url, options)
  end

  def parse_data(result, options={})
    return [result] if result[:error]
    return { error: result.fetch('pmc_web_stat', {}).fetch('response', {}).fetch('error', "an error occured") } if result.fetch('pmc_web_stat', {}).fetch('response', {}).fetch('status', 1) != "0"

    year = result.fetch('pmc_web_stat', {}).fetch('request', {}).fetch('year', nil)
    month = result.fetch('pmc_web_stat', {}).fetch('request', {}).fetch('month', nil)
    return [] if month.nil? || year.nil?

    items = result.fetch('pmc_web_stat', {}).fetch('articles', {}).fetch('article', [])

    Array(items).reduce([]) do |sum, item|
      doi = item.fetch('meta_data', {}).fetch('doi', nil)
      views = item.fetch('usage', {}).fetch('full_text', 0).to_i
      downloads = item.fetch('usage', {}).fetch('pdf', 0).to_i

      return sum if doi.blank? || (views + downloads == 0)

      subj_date = get_date_from_parts(year, month, 1)
      subj_id = "https://www.ncbi.nlm.nih.gov/pmc/#{year}/#{month}"
      subj = { "pid" => subj_id,
               "URL" => "https://www.ncbi.nlm.nih.gov/pmc",
               "title" => "PubMed Central",
               "type" => "webpage",
               "issued" => subj_date }

      if views > 0
        sum << { prefix: doi[/^10\.\d{4,5}/],
                 occurred_at: subj_date,
                 relation: { "subj_id" => subj_id,
                             "obj_id" => doi_as_url(doi),
                             "relation_type_id" => "views",
                             "total" => views,
                             "source_id" => "pmc_html" },
                 subj: subj }
      end

      if downloads > 0
        sum << { prefix: doi[/^10\.\d{4,5}/],
                 occurred_at: subj_date,
                 relation: { "subj_id" => subj_id,
                             "obj_id" => doi_as_url(doi),
                             "relation_type_id" => "downloads",
                             "total" => downloads,
                             "source_id" => "pmc_pdf" },
                 subj: subj }
      end

      sum
    end
  end

  def config_fields
    [:url]
  end

  def url
    "http://www.pubmedcentral.nih.gov/utils/publisher/pmcstat/pmcstat.cgi?year=%{year}&month=%{month}&jrid=%{journal}&user=%{username}&password=%{password}"
  end

  def cron_line
    config.cron_line || "0 5 9 * *"
  end

  def by_publisher?
    true
  end
end
