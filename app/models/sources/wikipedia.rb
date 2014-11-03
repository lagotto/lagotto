# encoding: UTF-8

class Wikipedia < Source
  # MediaWiki API Sandbox at http://en.wikipedia.org/wiki/Special:ApiSandbox
  def get_query_url(article, options={})
    host = options[:host] || "en.wikipedia.org"
    namespace = options[:namespace] || "0"
    url % { host: host, namespace: namespace, doi: CGI.escape("\"#{article.doi}\"") }
  end

  def get_data(article, options={})
    if article.doi.nil?
      result = {}
      result.extend Hashie::Extensions::DeepFetch
    else
      # Loop through the languages, create hash with languages as keys and counts as values
      languages.split(" ").reduce({}) do |sum, lang|
        host = (lang == "commons") ? "commons.wikimedia.org" : "#{lang}.wikipedia.org"
        namespace = (lang == "commons") ? "6" : "0"
        query_url = get_query_url(article, host: host, namespace: namespace)

        result = get_result(query_url, options)
        result.extend Hashie::Extensions::DeepFetch

        sum[lang] = result.deep_fetch('query', 'searchinfo', 'totalhits') { nil }
        sum
      end
    end
  end

  def parse_data(result, article, options={})
    events = result
    events['total'] = events.values.reduce(0) { |sum, x| x.nil? ? sum : sum + x } unless events.empty?
    event_count = events['total'].to_i

    { events: events,
      events_by_day: [],
      events_by_month: [],
      events_url: get_events_url(article),
      event_count: event_count,
      event_metrics: get_event_metrics(citations: event_count) }
  end

  def config_fields
    [:url, :events_url, :languages]
  end

  def url
    config.url || "http://%{host}/w/api.php?action=query&list=search&format=json&srsearch=%{doi}&srnamespace=%{namespace}&srwhat=text&srinfo=totalhits&srprop=timestamp&srlimit=1"
  end

  def events_url
    config.events_url || "http://en.wikipedia.org/w/index.php?search=\"%{doi}\""
  end

  def job_batch_size
    config.job_batch_size || 50
  end
end
