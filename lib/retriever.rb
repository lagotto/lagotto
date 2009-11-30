
class Retriever
  attr_accessor :lazy, :only_source, :verbose, :raise_on_error, :forceNow

  def initialize(options={})
    @lazy = options[:lazy]
    @verbose = options[:verbose] || 0
    @only_source = options[:only_source]
    @forceNow = options[:forceNow]
    @raise_on_error = options[:raise_on_error]
  end

  def update(article)
    if lazy and article.published_on and article.published_on >= Date.today
      puts "Skipping: not published yet" if verbose > 0
      return
    end

    sources = Source.active
    if only_source
      sources = sources.select {|s| s.name.downcase == only_source.downcase }
      if sources.empty?
        puts("Source '#{only_source}' not found or not active") if verbose > 0
        return
      end
    elsif sources.empty?
      puts("No active sources to update from")
      return
    end

    success = true
    sources.each do |source|
      puts("Considering #{source.inspect}") if verbose > 1
      retrieval = Retrieval.find_or_create_by_article_id_and_source_id(article.id, source.id)
      puts "Retrieval is#{" (new)" if retrieval.new_record?} #{retrieval.inspect} (lazy=#{lazy.inspect}, stale?=#{retrieval.stale?.inspect})" if verbose > 1
      
      if (not lazy) or retrieval.stale? or forceNow
        #If one fails, make note, but then keep going.
        result = update_one(retrieval, source, article)
        
        if(!result)
          RAILS_DEFAULT_LOGGER.warn "NOT refreshing article #{article.inspect}"
          success = false
        end
      end
    end
    if(success)
      article.refreshed!.save!
      puts "Refreshed article #{article.doi}"
    else
      puts "NOT refreshing article #{article.inspect}" if verbose > 0
    end
  end

  def update_one(retrieval, source, article)
    puts "Asking #{source.name} about #{article.doi}; last updated #{retrieval.retrieved_at}" if verbose > 1
    success = true
    begin
      raw_citations = source.query(article, :retrieval => retrieval,
                                   :verbose => verbose)
      if raw_citations.is_a? Numeric
        puts "  Got a count of #{raw_citations.inspect} citations." \
          if verbose > 1
        retrieval.other_citations_count = raw_citations
        retrieval.retrieved_at = DateTime.now.utc
      else
        # Uniquify them - Sources sometimes return duplicates
        preunique_count = raw_citations.size
        raw_citations = raw_citations.inject({}) do |h, citation|
          h[citation[:uri]] = citation; h
        end
        puts "  Got #{raw_citations.size} citation details." if verbose > 1
        dupCount = preunique_count - raw_citations.size
        puts "    (after filtering out #{dupCount} duplicates!)" \
          if (verbose > 1) and (dupCount > 0)
        existing = retrieval.citations.inject({}) do |h, citation|
          h[citation[:uri]] = citation; h
        end
    
        raw_citations.each do |uri, raw_citation|
          #if force save is true, don't bother deleting existing
          if source.force_save or existing.delete(uri).nil?
            begin
              citation = retrieval.citations.create(:uri => uri,
                :details => symbolize_keys_deeply(raw_citation))
            rescue
              raise if raise_on_error
              log_error("Unable to save #{raw_citation.inspect}")
              success = false
            end
          end
        end
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
      puts "  Saved history[#{history.id}: #{history.year}, #{history.month}] = #{history.citations_count}" if verbose > 1
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

  def log_error(msg)
    puts "ERROR: #{msg}: #{$!}"
    $!.backtrace.map {|line| puts "   #{line.sub(RAILS_ROOT, '')}" }
  end
end

