class Subscribers
  def self.notify(doi, source, previous_total, current_total)
    return unless current_total > previous_total
    low_end = previous_total + 1
    range = (low_end..current_total)
    journal = journal_key(doi)
    subs = list_for(journal, source)
    subs.each do |s|
      milestones = s[:milestones]
      # returns the last milestone in range
      hit = milestones.select{ |m| range.include?(m) }.last
      if hit
        Rails.logger.info("Notifying subscriber: #{{url: s[:url], doi: doi, milestone: hit}}")
        resp = Faraday.post(s[:url], doi: doi, milestone: hit)
        Rails.logger.info("Response from subscriber: #{resp.inspect}")
      end
    end
  end
  
  def self.journal_key(doi)
    prefix = '10.1371/journal.'
    return unless doi && doi.start_with?(prefix)
    doi.sub(prefix, '').split('.').first
  end

  def self.list_for(journal, source)
    subs = all_subscribers
    return subs.select { |s| s.values_at(:journal, :source) == [journal, source] }
  end

  def self.all_subscribers
    SUBSCRIBERS_CONFIG
  end
end
