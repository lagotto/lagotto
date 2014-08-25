# encoding: UTF-8

class ArticleCoverageCurated < Source
  def get_query_url(article)
    return nil unless article.doi =~ /^10.1371/

    url % { :doi => article.doi_escaped }
  end

  def response_options
    { metrics: :comments }
  end

  def get_events(result)
    Array(result['referrals']).map do |item|
      event_time = get_iso8601_from_time(item['published_on'])
      url = item['referral']

      { event: item,
        event_time: event_time,
        event_url: url,

        # the rest is CSL (citation style language)
        event_csl: {
          'author' => '',
          'title' => item.fetch('title') { '' },
          'container-title' => item.fetch('publication') { '' },
          'issued' => get_date_parts(event_time),
          'url' => url,
          'type' => get_csl_type(item['type']) }
        }
    end
  end

  def get_csl_type(type)
    return nil if type.blank?

    types = { 'Blog' => 'post',
              'News' => 'article-newspaper',
              'Podcast/Video' => 'broadcast',
              'Lab website/homepage' => 'webpage',
              'University page' => 'webpage' }
    types[type]
  end

  def config_fields
    [:url]
  end
end
