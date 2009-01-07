
class Retriever
  attr_accessor :lazy, :only_source, :verbose, :raise_on_error

  def initialize(options={})
    @lazy = options[:lazy] || false
    @verbose = options[:verbose] || false
    @only_source = options[:only_source]
    @raise_on_error = options[:raise_on_error] || false
  end

  def update(article)
    Source.active.each do |source|
      if only_source.nil? or (source.name.downcase == only_source.downcase)
        puts "Considering #{source.inspect}" if verbose
        retrieval = Retrieval.find_or_create_by_article_id_and_source_id(article.id, source.id)
        puts "Retrieval is#{" (new)" if retrieval.new_record?} #{retrieval.inspect}" if verbose
        if (not lazy) or retrieval.stale?
          update_one(retrieval, source, article)
        end
      end
    end
    article.refreshed!.save!
  end

  def update_one(retrieval, source, article)
    puts "Asking #{source.name} about #{article.doi}; last updated #{retrieval.retrieved_at}" if verbose
    begin
      raw_citations = source.query(article)
      if raw_citations.is_a? Numeric
        puts "  Got a count of #{raw_citations.inspect} citations." if verbose
        retrieval.other_citations_count = raw_citations
      else
        puts "  Got #{raw_citations.length} citation details." if verbose
        existing = retrieval.citations.inject({}) do |h, citation|
          h[citation[:uri]] = citation; h
        end
    
        raw_citations.each do |raw_citation|
          if existing.delete(raw_citation[:uri]).nil?
            begin
              citation = retrieval.citations.create(:uri => raw_citation[:uri],
                :details => symbolize_keys_deeply(raw_citation))
            rescue
              puts "  Unable to save #{raw_citation.inspect}: #{$!}"
            end
          end
        end
        existing.values.map(&:destroy)
      end
    rescue
      raise if raise_on_error
      puts "  Unable to query: #{$!}"
    end

    retrieval.reload.retrieved_at = DateTime.now.utc
    retrieval.save!

    history = retrieval.histories.find_or_create_by_year_and_month(retrieval.retrieved_at.year, retrieval.retrieved_at.month)
    history.citations_count = retrieval.total_citations_count
    history.save!
    puts "  Saved history[#{history.id}: #{history.year}, #{history.month}] = #{history.citations_count}" if verbose
  end

  def symbolize_keys_deeply(h)
    result = h.symbolize_keys
    result.each do |k,v|
      result[k] = symbolize_keys_deeply(v) if v.is_a? Hash
    end
    result
  end
end
