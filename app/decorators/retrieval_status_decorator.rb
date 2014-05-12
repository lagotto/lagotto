class RetrievalStatusDecorator < Draper::Decorator
  # helper methods
  include Measurable

  delegate_all
  decorates_association :article

  def group_name
    group.name
  end

  def events
    unless context[:days] || context[:months] || context[:year]
      model.events.blank? ? [] : model.events
    else
      retrieval_history.blank? ? [] : retrieval_history.events
    end
  end

  def metrics
    return event_metrics unless event_metrics.nil?

    case name
    when "citeulike"
      { :pdf => nil, :html => nil, :shares => event_count, :groups => nil, :comments => nil, :likes => nil, :citations => nil, :total => event_count }
    when "facebook"
      if events.kind_of? Hash
        { :pdf => nil, :html => nil, :shares => events["share_count"], :groups => nil, :comments => events["comment_count"], :likes => events["like_count"], :citations => nil, :total => event_count }
      elsif events.kind_of? Array
        { :pdf => nil, :html => nil, :shares => events.reduce(0) { |sum, hash| sum + hash["share_count"] }, :groups => nil, :comments => events.reduce(0) { |sum, hash| sum + hash["comment_count"] }, :likes => events.reduce(0) { |sum, hash| sum + hash["like_count"] }, :citations => nil, :total => event_count }
      else
        { :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => nil, :total => event_count }
      end
    when "mendeley"
      { :pdf => nil, :html => nil, :shares => (events.blank? ? nil : events['stats']['readers']), :groups => (events.blank? || events['groups'].nil? ? nil : events['groups'].length), :comments => nil, :likes => nil, :citations => nil, :total => event_count }
    when "counter"
      { :pdf => (events.blank? ? nil : events.reduce(0) { |sum, hash| sum + hash[:pdf_views].to_i }), :html => (events.blank? ? nil : events.reduce(0) { |sum, hash| sum + hash[:html_views].to_i }), :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => nil, :total => event_count }
    when "biod"
      { :pdf => (events.blank? ? nil : events.reduce(0) { |sum, hash| sum + hash[:pdf_views].to_i }), :html => (events.blank? ? nil : events.reduce(0) { |sum, hash| sum + hash[:html_views].to_i }), :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => nil, :total => event_count }
    when "pmc"
      { :pdf => (events.blank? ? nil : events.reduce(0) { |sum, hash| sum + hash["pdf"].to_i }), :html => (events.blank? ? nil : events.reduce(0) { |sum, hash| sum + hash["full-text"].to_i }), :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => nil, :total => event_count }
    when "copernicus"
      { :pdf => (events.blank? ? nil : events['counter']['PdfDownloads'].to_i), :html => (events.blank? ? nil : events['counter']['AbstractViews'].to_i), :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => nil, :total => event_count }
    when "twitter"
      { :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => event_count, :likes => nil, :citations => nil, :total => event_count }
    else
    # crossref, pubmed, researchblogging, nature, scienceseeker, wikipedia, pmceurope, pmceuropedata, wordpress, openedition
      { :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => event_count, :total => event_count }
    end
  end

  def by_year
    return [] if by_month.blank?

    by_month.group_by { |event| event["year"] }.sort.map do |k, v|
      if ['counter', 'pmc', 'figshare', 'copernicus'].include?(name)
        { year: k.to_i,
          pdf: v.reduce(0) { |sum, hash| sum + hash['pdf'].to_i },
          html: v.reduce(0) { |sum, hash| sum + hash['html'].to_i } }
      else
        { year: k.to_i,
          total: v.reduce(0) { |sum, hash| sum + hash['total'].to_i } }
      end
    end
  end

  # Get most current retrieval_history by query parameters :days, :months, :year
  def retrieval_histories
    if context[:days].to_i > 0
      model.retrieval_histories.after_days(context[:days].to_i)
    elsif context[:months].to_i > 0
      model.retrieval_histories.after_months(context[:months].to_i)
    elsif context[:year].to_i > 0
      model.retrieval_histories.until_year(context[:year].to_i)
    else
      model.retrieval_histories
    end
  end

  def retrieval_history
    retrieval_histories.first
  end

  def update_date
    unless context[:days] || context[:months] || context[:year]
      updated_at.utc.iso8601
    else
      retrieval_history.blank? ? nil : retrieval_history.updated_at.utc.iso8601
    end
  end

  def event_count
    unless context[:days] || context[:months] || context[:year]
      model.event_count
    else
      retrieval_history.nil? ? nil : retrieval_history.event_count
    end
  end

  def event_metrics
    unless context[:days] || context[:months] || context[:year]
      model.event_metrics
    else
      retrieval_history.blank? ? nil : retrieval_history.metrics
    end
  end

  def events_csl
    return [] unless model.events.is_a?(Array)

    model.events.reduce([]) { |sum, event| sum << event['event_csl'] if event['event_csl'] }
  end

  def histories
    retrieval_histories.blank? ? [] : retrieval_histories.map { |rh| { :update_date => rh.updated_at.utc.iso8601, :total => rh.event_count } }
  end

  def cache_key
    { :id => id,
      :timestamp => updated_at.to_s(:number),
      :info => context[:info],
      :days => context[:days],
      :months => context[:months],
      :year => context[:year] }
  end
end
