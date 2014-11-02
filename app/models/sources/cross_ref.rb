# encoding: UTF-8

class CrossRef < Source
  def get_query_url(article)
    return nil if article.doi.nil? || Time.zone.now - article.published_on.to_time < 1.day

    if article.publisher_id.present?
      # check that we have publisher-specific configuration
      pc = publisher_config(article.publisher_id)
      return nil if pc.username.nil? || pc.password.nil?

      url % { :username => pc.username, :password => pc.password, :doi => article.doi_escaped }
    else
      return nil if openurl_username.nil?

      openurl % { :openurl_username => openurl_username, :doi => article.doi_escaped }
    end
  end

  def request_options
    { content_type: 'xml' }
  end

  def parse_data(result, article)
    return result if result[:error]

    events = get_events(result)

    if article.publisher
      event_count = events.length
    else
      event_count = result.deep_fetch('crossref_result', 'query_result', 'body', 'query', 'fl_count') { 0 }
    end

    { events: events,
      events_by_day: [],
      events_by_month: [],
      events_url: nil,
      event_count: event_count.to_i,
      event_metrics: get_event_metrics(citations: event_count) }
  end

  def get_events(result)
    events = result.deep_fetch('crossref_result', 'query_result', 'body', 'forward_link') { nil }
    if events.is_a?(Hash) && events['journal_cite']
      events = [events]
    elsif events.is_a?(Hash)
      events = nil
    end

    Array(events).map do |item|
      item = item.fetch('journal_cite') { {} }
      if item.empty?
        nil
      else
        url = Article.to_url(item['doi'])

        { event: item,
          event_url: url,

          # the rest is CSL (citation style language)
          event_csl: {
            'author' => get_author(item.fetch('contributors', {}).fetch('contributor', [])),
            'title' => String(item.fetch('article_title') { '' }).titleize,
            'container-title' => item.fetch('journal_title') { '' },
            'issued' => get_date_parts_from_parts(item['year']),
            'url' => url,
            'type' => 'article-journal' } }
      end
    end.compact
  end

  def get_author(contributors)
    contributors = [contributors] if contributors.is_a?(Hash)
    contributors.map do |contributor|
      { 'family' => String(contributor['surname']).titleize,
        'given' => String(contributor['given_name']).titleize }
    end
  end

  def config_fields
    [:url, :openurl, :username, :password, :openurl_username]
  end

  def url
    config.url || "http://doi.crossref.org/servlet/getForwardLinks?usr=%{username}&pwd=%{password}&doi=%{doi}"
  end

  def openurl
    config.openurl || "http://www.crossref.org/openurl/?pid=%{openurl_username}&id=doi:%{doi}&noredirect=true"
  end

  def openurl=(value)
    config.openurl = value
  end

  def timeout
    config.timeout || 120
  end

  def workers
    config.workers || 10
  end

  def by_publisher?
    true
  end
end
