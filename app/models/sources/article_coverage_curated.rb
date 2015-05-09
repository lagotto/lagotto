class ArticleCoverageCurated < Source
  # include common methods for Article Coverage
  include Coverable

  def get_extra(result)
    Array(result.fetch('referrals', nil)).map do |item|
      event_time = get_iso8601_from_time(item['published_on'])
      url = item['referral']
      type = item.fetch("type", nil)
      type = MEDIACURATION_TYPE_TRANSLATIONS.fetch(type, nil) if type

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
          'type' => type }
        }
    end
  end
end
