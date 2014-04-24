class RetrievalStatusDecorator < Draper::Decorator
  # include metrics by day, month and year
  include Visualizable

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
    when "citeulike" then get_event_metrics(shares: event_count)
    when "mendeley"
      shares = events.blank? ? nil : events['stats']['readers']
      groups = events.blank? || events['groups'].nil? ? nil : events['groups'].length
      get_event_metrics(shares: shares, groups: groups, total: event_count)

    when "facebook" then get_event_metrics(shares: events["share_count"], comments: events["comment_count"], likes: events["like_count"], total: event_count)
    when "twitter" then get_event_metrics(comments: event_count)

    when "counter", "biod"
      pdf = events.blank? ? nil : events.reduce(0) { |sum, hash| sum + hash[:pdf_views].to_i }
      html = events.blank? ? nil : events.reduce(0) { |sum, hash| sum + hash[:html_views].to_i }
      get_event_metrics(pdf: pdf, html: html, total: event_count)
    when "pmc"
      pdf = events.blank? ? nil : events.reduce(0) { |sum, hash| sum + hash["pdf"].to_i }
      html = events.blank? ? nil : events.reduce(0) { |sum, hash| sum + hash["full-text"].to_i }
      get_event_metrics(pdf: pdf, html: html, total: event_count)
    when "copernicus"
      pdf = events.blank? ? nil : events['counter']['PdfDownloads'].to_i
      html = events.blank? ? nil : events['counter']['AbstractViews'].to_i
      get_event_metrics(pdf: pdf, html: html, total: event_count)

    else get_event_metrics(citations: event_count)
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
