class MetricsDecorator < RetrievalStatusDecorator

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

    when "counter", "biod"
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

end
