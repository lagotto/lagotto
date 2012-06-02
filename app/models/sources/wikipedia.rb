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
      offset = 0
      
      until offset < 0    

        query_url = get_query_url(article, :host => host, :offset => offset)
        results = get_json(query_url, options) 

        lang_total = results['query']['searchinfo']['totalhits']
        offset = results['query-continue'] ? results['query-continue']['search']['sroffset'] : -1
        
        lang_events = (results['query']['search']).map do |result|
          url = "http://#{host}/wiki/#{result['title'].gsub( / +/, "_")}"
          
          {:url => url,    
           :title => result['title'], 
           :last_edited_at => result['timestamp'],        
           :lang => lang,
           :namespace => result['ns']}
        end
  
        events.concat(lang_events)
      end
      
      total += lang_total
    end
    
    # Check that we have collected all events
    missed_count = total - events.length
    duplicate_count = events.length - events.uniq.length
    raise "collected wrong number of events" if (missed_count > 0 or duplicate_count > 0)
    
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
    
    host = options[:host] || "en.wikipedia.org"
    namespace = options[:namespace] || "0%7C2%7C6"
    offset = options[:offset] || 0
    limit = options[:limit] || 50
    
    # http://%{host}/w/api.php?action=query&list=search&format=json&srsearch=%{doi}&srnamespace=%{namespace}&srwhat=text&srinfo=totalhits&srprop=timestamp&sroffset=%{offset}&srlimit=%{limit}"
    config.url % { :host => host, :doi => CGI.escape(article.doi), :namespace => namespace, :offset => offset, :limit => limit }
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