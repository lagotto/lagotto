class RetrievalStatusDecorator < Draper::Decorator
  delegate_all
  decorates_association :article

  def events
    unless context[:days] || context[:months] || context[:year]
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
      # crossref, pubmed, researchblogging, nature, scienceseeker, wikipedia, pmceurope, pmceuropedata, wordpress, openedition
        { :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => event_count, :total => event_count }
      end
    end
  end

  def by_day
    case name
    when "citeulike"
      return nil if events.blank?
      events_30 = events.select { |event| event["event"]["post_time"].to_date - article.published_on < 30 }
      return nil if events_30.blank?
      events_30.group_by {|event| event["event"]["post_time"].to_datetime.strftime("%Y-%m-%d") }.sort.map {|k,v| { :year => k[0..3].to_i, :month => k[5..6].to_i, :day => k[8..9].to_i, :pdf => nil, :html => nil, :shares => v.length, :groups => nil, :comments => nil, :likes => nil, :citations => nil, :total => v.length }}
    when "researchblogging"
      return nil if events.blank?
      events_30 = events.select { |event| event["event"]["published_date"].to_date - article.published_on < 30 }
      return nil if events_30.blank?
      events_30.group_by {|event| event["event"]["published_date"].to_datetime.strftime("%Y-%m-%d") }.sort.map {|k,v| { :year => k[0..3].to_i, :month => k[5..6].to_i, :day => k[8..9].to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => v.length, :total => v.length }}
    when "scienceseeker"
      return nil if events.blank?
      events_30 = events.select { |event| event["event"]["updated"].to_date - article.published_on < 30 }
      return nil if events_30.blank?
      events_30.group_by {|event| event["event"]["updated"].to_datetime.strftime("%Y-%m-%d") }.sort.map {|k,v| { :year => k[0..3].to_i, :month => k[5..6].to_i, :day => k[8..9].to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => v.length, :total => v.length }}
    when "wordpress"
      return nil if events.blank?
      events_30 = events.select { |event| Time.at(event["event"]["epoch_time"].to_i).to_date - article.published_on < 30 }
      return nil if events_30.blank?
      events_30.group_by {|event| Time.at(event["event"]["epoch_time"].to_i).to_datetime.strftime("%Y-%m-%d") }.sort.map {|k,v| { :year => k[0..3].to_i, :month => k[5..6].to_i, :day => k[8..9].to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => v.length, :total => v.length }}
    when "openedition"
      return nil if events.blank?
      events_30 = events.select { |event| Time.at(event["event"]["epoch_time"].to_i).to_date - article.published_on < 30 }
      return nil if events_30.blank?
      events_30.group_by {|event| event["event"]["date"].to_datetime.strftime("%Y-%m-%d") }.sort.map {|k,v| { :year => k[0..3].to_i, :month => k[5..6].to_i, :day => k[8..9].to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => v.length, :total => v.length }}
    when "twitter_search"
      return nil if events.blank?
      events_30 = events.select { |event| event["event"]["created_at"].to_date - article.published_on < 30 }
      return nil if events_30.blank?
      events_30.group_by {|event| event["event"]["created_at"].to_datetime.strftime("%Y-%m-%d") }.sort.map {|k,v| { :year => k[0..3].to_i, :month => k[5..6].to_i, :day => k[8..9].to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => v.length, :likes => nil, :citations => nil, :total => v.length }}
    else
    # crossref, facebook, mendeley, pubmed, nature, scienceseeker, copernicus, wikipedia
      nil
    end
  end


  def by_month
    case name
    when "citeulike"
      if events.blank?
        nil
      else
        events.group_by {|event| event["event"]["post_time"].to_datetime.strftime("%Y-%m") }.sort.map {|k,v| { :year => k[0..3].to_i, :month => k[5..6].to_i, :pdf => nil, :html => nil, :shares => v.length, :groups => nil, :comments => nil, :likes => nil, :citations => nil, :total => v.length }}
      end
    when "researchblogging"
      if events.blank?
        nil
      else
        events.group_by {|event| event["event"]["published_date"].to_datetime.strftime("%Y-%m") }.sort.map {|k,v| { :year => k[0..3].to_i, :month => k[5..6].to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => v.length, :total => v.length }}
      end
    when "scienceseeker"
      if events.blank?
        nil
      else
        events.group_by {|event| event["event"]["updated"].to_datetime.strftime("%Y-%m") }.sort.map {|k,v| { :year => k[0..3].to_i, :month => k[5..6].to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => v.length, :total => v.length }}
      end
    when "wordpress"
      if events.blank?
        nil
      else
        events.group_by {|event| Time.at(event["event"]["epoch_time"].to_i).to_datetime.strftime("%Y-%m") }.sort.map {|k,v| { :year => k[0..3].to_i, :month => k[5..6].to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => v.length, :total => v.length }}
      end
    when "openedition"
      if events.blank?
        nil
      else
        events.group_by {|event| event["event"]["date"].to_datetime.strftime("%Y-%m") }.sort.map {|k,v| { :year => k[0..3].to_i, :month => k[5..6].to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => v.length, :total => v.length }}
      end
    when "twitter_search"
      if events.blank?
        nil
      else
        events.group_by {|event| event["event"]["created_at"].to_datetime.strftime("%Y-%m") }.sort.map {|k,v| { :year => k[0..3].to_i, :month => k[5..6].to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => v.length, :likes => nil, :citations => nil, :total => v.length }}
      end
    else
    # crossref, facebook, mendeley, pubmed, nature, scienceseeker, copernicus, wikipedia
      nil
    end
  end

  def by_year
    case name
    when "citeulike"
      if events.blank?
        nil
      else
        events.group_by {|event| event["event"]["post_time"].to_datetime.year }.sort.map {|k,v| { :year => k.to_i, :pdf => nil, :html => nil, :shares => v.length, :groups => nil, :comments => nil, :likes => nil, :citations => nil, :total => v.length }}
      end
    when "crossref"
      if events.blank?
        nil
      else
        events.group_by {|event| event["event"]["year"] }.sort.map {|k,v| { :year => k.to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => v.length, :total => v.length }}
      end
    when "researchblogging"
      if events.blank?
        nil
      else
        events.group_by {|event| event["event"]["published_date"].to_datetime.year }.sort.map {|k,v| { :year => k.to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => v.length, :total => v.length }}
      end
    when "scienceseeker"
      if events.blank?
        nil
      else
        events.group_by {|event| event["event"]["updated"].to_datetime.year }.sort.map {|k,v| { :year => k.to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => v.length, :total => v.length }}
      end
    when "wordpress"
      if events.blank?
        nil
      else
        events.group_by {|event| Time.at(event["event"]["epoch_time"].to_i).to_datetime.year }.sort.map {|k,v| { :year => k.to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => v.length, :total => v.length }}
      end
    when "openedition"
      if events.blank?
        nil
      else
        events.group_by {|event| event["event"]["date"].to_datetime.year }.sort.map {|k,v| { :year => k.to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => v.length, :total => v.length }}
      end
    when "twitter_search"
      if events.blank?
        nil
      else
        events.group_by {|event| event["event"]["created_at"].to_datetime.year }.sort.map {|k,v| { :year => k.to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => v.length, :likes => nil, :citations => nil, :total => v.length }}
      end
    else
    # facebook, mendeley, pubmed, nature, scienceseeker, copernicus, wikipedia
      nil
    end
  end

  def cache_key
    { :id => id,
      :timestamp => updated_at,
      :info => context[:info],
      :days => context[:days],
      :months => context[:months],
      :year => context[:year] }
  end
end
