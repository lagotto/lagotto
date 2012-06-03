class Wikipedia < Source
  # List of Wikipedias to search, we are using 20 most popular wikis
  # Taken from http://toolserver.org/~dartar/cite-o-meter/?doip=10.1371
  LANGUAGES = %w(en de fr it pl es ru ja nl pt sv zh ca uk no fi vi cs hu ko commons)
  
  validates_each :url do |record, attr, value|
    record.errors.add(attr, "can't be blank") if value.blank?
  end

  def get_data(article, options={})

    events = []
    total = 0
    
    # Loop through the languages
    LANGUAGES.each do |lang|
      
      host = (lang == "commons") ? "commons.wikimedia.org" : "#{lang}.wikipedia.org"
      lang_events = []
      offset = 0
      
      until offset < 0    

        query_url = get_query_url(article, :host => host, :offset => offset)
        results = get_json(query_url, options) 
        
        # Raise error if server returns an error (usually either exceeeding maxlag or text search disabled errors)
        raise ResponseError, results['error']['info'], [query_url, results.to_s] unless results['error'].blank?

        lang_total = results['query']['searchinfo']['totalhits']
        offset = results['query-continue'] ? results['query-continue']['search']['sroffset'] : -1
        
        temp_events = (results['query']['search']).map do |result|
          url = "http://#{host}/wiki/#{result['title'].gsub( / +/, "_")}"
          
          {:url => url,    
           :title => result['title'], 
           :last_edited_at => result['timestamp'],        
           :lang => lang,
           :namespace => result['ns']}
        end
        lang_events.concat(temp_events)
      end
      
      # Check that we have correctly collected all events. Check for duplicates and compare to "totalhits" provided by Mediawiki
      # Raise an error and don't store results if numbers don't match
      missing_count = lang_total - lang_events.uniq.length
      raise ResponseError, "missed #{missing_count} out of #{lang_total} event(s) for host #{host}", [query_url, results.to_s] if missing_count != 0
      
      events.concat(lang_events)
      total += lang_total
    end
    
    {:events => events, 
     :event_count => total}
  end
  
  def get_query_url(article, options={})
    # Build URL for calling the MediaWiki API, using the following parameters:
    #
    # host - the Mediawiki to search, default en.wikipedia.org (English Wikipedia)
    # doi - the DOI to search for, uses article.doi
    # namespace - the namespace number(s) to search, default 0 (Main), 2 (User) and 6 (File). Separate numbers by | character, encoded as %7C
    # offset - offset for retrieveing results, default 0
    # limit - the number of results to return, default  50
    # maxlag - maximal slave server lag in seconds, default 10
    #
    # API Sandbox at http://en.wikipedia.org/wiki/Special:ApiSandbox
    
    host = options[:host] || "en.wikipedia.org"
    namespace = options[:namespace] || "0%7C2%7C6"
    offset = options[:offset] || 0
    limit = options[:limit] || 50
    maxlag = options[:maxlag] || 10
    
    # http://%{host}/w/api.php?action=query&list=search&format=json&srsearch=%{doi}&srnamespace=%{namespace}&srwhat=text&srinfo=totalhits&srprop=timestamp&sroffset=%{offset}&srlimit=%{limit}&maxlag=%{maxlag}"
    config.url % { :host => host, :doi => CGI.escape(article.doi), :namespace => namespace, :offset => offset, :limit => limit, :maxlag => maxlag }
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