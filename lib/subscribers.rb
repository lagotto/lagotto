class Subscribers
  def self.notify(doi, source, previous_total, current_total )
    return unless current_total > previous_total
    range = (previous_total...current_total)
    subs = get(doi, source)
    subs.each do |s|
      milestones = s[:milestones]
      # returns the last milestone in range
      hit = milestones.select{ |m| range.include?(m) }.last
      if hit
        Faraday.get(s[:url], doi: doi, milestone: hit)
      end
    end
  end

  def self.get(doi, source)
    journal = journal_key(doi)
    subs = get_from_config
    return subs.select { |s| s.values_at(:journal, :source) == [journal, source] }
  end

  def self.get_from_config
    SUBSCRIBERS_CONFIG[:subscribers]
  end

  def self.journal_key(doi)
    prefix = '10.1371/journal.'
    return unless doi && doi.start_with?(prefix)
    doi.sub(prefix, '').split('.').first
  end
end
