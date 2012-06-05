class ScopusRest < Source
  
  validates_each :api_key, :partner_id do |record, attr, value|
    record.errors.add(attr, "can't be blank") if value.blank?
  end
  
  def get_data(article, options={})
    raise(ArgumentError, "#{display_name} configuration requires partner_id") \
      if config.partner_id.blank?

    options[:extraheaders] = { "Accept"  => "application/json", "X-ELS-APIKey" => config.api_key, "X-ELS-ResourceVersion" => "XOCS" }
    
    query_url = get_query_url(article, options)
    results = get_json(query_url, options) 
    
    events = results["search-results"]["entry"]

    # Workaround if Scopus returns more than one result for a given DOI (which it shouldn't)
    events = events[0] if events.is_a? Array
    
    total = events["citedby-count"].to_i
    scopus_id = events["dc:identifier"][10..-1]

    event_url = get_event_url(scopus_id)

    {:events => events,
     :events_url => event_url,
     :event_count => total,
     :local_id => scopus_id}}
  end
  
  def get_query_url(article, options={})
    # http://api.elsevier.com/content/search/index:SCOPUS?query=doi(%{doi})"
    config.url % { :doi => CGI.escape(article.doi) }
  end
  
  def get_event_url(scopus_id, options={})
    # http://www.scopus.com/inward/citedby.url?partnerID=%{partner_id}&scp=%{scopus_id}"
    config.event_url % { :partner_id => config.partner_id, :scopus_id => scopus_id }
  end
  
  def get_config_fields
    [{:field_name => "api_key", :field_type => "text_field"},
    {:field_name => "partner_id", :field_type => "text_field"}]
  end

  def partner_id
    config.partner_id
  end
  
  def partner_id=(value)
    config.partner_id = value
  end
  
end