class Retriever
  include Log
  attr_accessor :lazy, :only_source, :verbose, :raise_on_error

  def initialize(options={})
    if options[:lazy] == nil
      raise(ArgumentError, "Lazy must be specified as true or false")
    end
    
    @lazy = options[:lazy]
    @verbose = options[:verbose] || 0
    @only_source = options[:only_source]
    @raise_on_error = options[:raise_on_error]
  end

  def update(article)
    if lazy and article.published_on and article.published_on >= Date.today
      log_info("Skipping: not published yet")
     
      return
    end

    sources = Source.active
    if only_source
      sources = sources.select {|s| s.name.downcase == only_source.downcase }
      if sources.empty?
        log_info("Source '#{only_source}' not found or not active") 
        
        return
      end
    elsif sources.empty?
      log_info("No active sources to update from")
      return
    end

    sources_count = 0
    
    sources.each do |source|
      retrieval = Retrieval.find_or_create_by_article_id_and_source_id(article.id, source.id)
      log_info("Retrieval is#{" (new)" if retrieval.new_record?} #{retrieval.inspect} (lazy=#{lazy.inspect}, stale?=#{retrieval.stale?.inspect})")
      
      if (not lazy) or retrieval.stale?
        log_info("Refreshing Source: #{source.inspect}") 
        #If one fails, make note, but then keep going.
        result = update_one(retrieval, source, article)
        
        if(result)
          sources_count = sources_count + 1
          log_info("result=#{result}, sources_count incremented: #{sources_count}")
        else
          log_info("result=#{result}, Error refreshing article #{article.inspect}")
        end
      else
        sources_count = sources_count + 1
        log_info("Not refreshing source #{source.inspect}")
      end
    end
    # If we are updating only one source
    #     do NOT update the article as refreshed
    # If all the sources do not update successfully
    #     do NOT update the article as refreshed
    if(sources_count == sources.size and not only_source)
      article.refreshed!.save!
      log_info("Refreshed article #{article.doi}")
    else
      log_info("NOT refreshing article #{article.doi} count: #{sources_count} only src: #{only_source}")
    end
  end

  def update_one(retrieval, source, article)
    log_info("Asking #{source.name} about #{article.doi}; last updated #{retrieval.retrieved_at}") 
    
    success = true
    begin
      raw_citations = source.query(article, { :retrieval => retrieval, 
        :verbose => verbose, :timeout => source.timeout })
      #Scopus returns a numeric count
      if raw_citations.is_a? Numeric
        log_info("Got a count of #{raw_citations.inspect} citations.")
          
        retrieval.other_citations_count = raw_citations
        retrieval.retrieved_at = DateTime.now.utc
      else
        # Uniquify them - Sources sometimes return duplicates
        preunique_count = raw_citations.size
        raw_citations = raw_citations.inject({}) do |h, citation|
          h[citation[:uri]] = citation; h
        end
        log_info("Got #{raw_citations.size} citation details.")
        
        dupCount = preunique_count - raw_citations.size
        
        log_info("(after filtering out #{dupCount} duplicates!)")
            
        #Uniquify existing citations
        log_info("Existing Citation Count: #{retrieval.citations.size}" )
        existing = retrieval.citations.inject({}) do |h, citation|
          h[citation[:uri]] = citation; h
        end
        log_info("After existing citations uniquified: #{existing.size}")
    
        raw_citations.each do |uri, raw_citation|
          #Loop through all citations, updating old, creating new.
          #Remove any old ones from the hash.
          dbCitation = existing.delete(uri)
          if dbCitation.nil?
            begin
              log_info("Creating Citation")
              citation = retrieval.citations.create(:uri => uri,
                :details => symbolize_keys_deeply(raw_citation))
              rescue
                raise if raise_on_error
                log_error("Unable to Create #{raw_citation.inspect}")
                success = false
            end
          else
            begin
              log_info("Updating Citation: " + dbCitation.id.to_s)
              citation = retrieval.citations.update(dbCitation.id, {:details => symbolize_keys_deeply(raw_citation), :updated_at => DateTime.now })
              rescue
                raise if raise_on_error
                log_error("Unable to Update #{raw_citation.inspect}")
                success = false
            end
          end
        end
        
        #delete any existing database records that are still in the hash
        #(This will occur if a citation was created, but the later the source
        #giving us the citation stopped sending it
        log_info("Deleting remaining Existing Citations: #{existing.size}")
        existing.values.map(&:destroy)
        retrieval.retrieved_at = DateTime.now.utc
      end
      retrieval.save!
    rescue
      raise if raise_on_error
      log_error("Unable to query")
      success = false
    rescue Timeout::Error
      raise if raise_on_error
      log_error("Unable to query (timeout)")
      success = false
    end

    if success
      retrieval.reload
      history = retrieval.histories.find_or_create_by_year_and_month(retrieval.retrieved_at.year, retrieval.retrieved_at.month)
      history.citations_count = retrieval.total_citations_count
      history.save!
      log_info("Saved history[#{history.id}: #{history.year}, #{history.month}] = #{history.citations_count}")
    end
    success
  end

  def symbolize_keys_deeply(h)
    result = h.symbolize_keys
    result.each do |k,v|
      result[k] = symbolize_keys_deeply(v) if v.is_a? Hash
    end
    result
  end
end

