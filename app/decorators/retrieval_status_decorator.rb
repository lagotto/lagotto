class RetrievalStatusDecorator < Draper::Decorator
  delegate_all
  
  def events
    unless context[:days] || context[:month] || context[:year]
      model.events.blank? ? [] : model.events
    else
      retrieval_history.blank? ? [] : retrieval_history.events
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
    unless context[:days] || context[:month] || context[:year]
      updated_at.utc.iso8601
    else
      retrieval_history.blank? ? nil : retrieval_history.updated_at.utc.iso8601
    end
  end
  
  def event_count
    unless context[:days] || context[:month] || context[:year]
      model.event_count
    else
      retrieval_history.nil? ? nil : retrieval_history.event_count
    end
  end
  
  def event_metrics
    unless context[:days] || context[:month] || context[:year]
      model.event_metrics
    else
      retrieval_history.blank? ? nil : retrieval_history.metrics
    end
  end
  
  def histories
    retrieval_histories.blank? ? [] : retrieval_histories.map { |rh| { :update_date => rh.updated_at.utc.iso8601, :total => rh.event_count } }
  end
  
  def metrics
    unless event_metrics.nil? 
      event_metrics
    else
      case name
      when "citeulike"
        { :pdf => nil, :html => nil, :shares => event_count, :groups => nil, :comments => nil, :likes => nil, :citations => nil, :total => event_count }
      when "facebook"
        if events.kind_of? Hash
          { :pdf => nil, :html => nil, :shares => events["share_count"], :groups => nil, :comments => events["comment_count"], :likes => events["like_count"], :citations => nil, :total => event_count }
        elsif events.kind_of? Array
          { :pdf => nil, :html => nil, :shares => events.inject(0) { |sum, hash| sum + hash["share_count"] }, :groups => nil, :comments => events.inject(0) { |sum, hash| sum + hash["comment_count"] }, :likes => events.inject(0) { |sum, hash| sum + hash["like_count"] }, :citations => nil, :total => event_count }
        else
          { :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => nil, :total => event_count } 
        end
      when "mendeley"
        { :pdf => nil, :html => nil, :shares => (events.blank? ? nil : events['stats']['readers']), :groups => (events.blank? or events['groups'].nil? ? nil : events['groups'].length), :comments => nil, :likes => nil, :citations => nil, :total => event_count }
      when "copernicus"
        { :pdf => (events.blank? ? nil : events['counter']['PdfDownloads'].to_i), :html => (events.blank? ? nil : events['counter']['AbstractViews'].to_i), :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => nil, :total => event_count }
      else
      # crossref, pubmed, researchblogging, nature, scienceseeker, wikipedia
        { :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => event_count, :total => event_count }
      end
    end
  end
end
