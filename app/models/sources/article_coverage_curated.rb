class ArticleCoverageCurated < Source

  include SourceHelper

  validates_each :url do |record, attr, value|
    record.errors.add(attr, "can't be blank") if value.blank?
  end

  def get_data(article, options={})
    raise(ArgumentError, "The Article Coverage Curated configuration requires a url") \
      if url.blank?

    return  { :events => [], :event_count => nil } if article.doi.blank?

    query_url = get_query_url(article)
    result = get_json(query_url, options)

    if result.nil?
      { events: [], event_count: 0 }
    else
      # look for the referrals
      referrals = result['referrals']

      if (referrals.blank?)
        { events: [], event_count: 0 }
      else
        events = referrals.map { |item| { event: item, event_url: item['referral'] }}

        event_metrics = { pdf: nil,
                          html: nil,
                          shares: nil,
                          groups: nil,
                          comments: nil,
                          likes: nil,
                          citations: nil,
                          total: events.length }

        { events: events,
          event_count: events.length,
          event_metrics: event_metrics }
      end
    end

  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"}]
  end

  def url
    config.url
  end

  def url=(value)
    config.url = value
  end

end
