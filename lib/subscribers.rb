class Subscribers
  def self.get_subscribers(journal, source)
    subs = SUBSCRIBERS_CONFIG[:subscribers]
    return subs.select { |s| s.values_at(:journal, :source) == [journal, source] }
  end

  def self.notify_subscribers(doi, journal_key, source_name, previous_total, current_total )
    return unless current_total > previous_total
    range = (previous_total..current_total)

    subs = get_subscribers(journal_key, source_name)
    subs.each do |s|
      next unless s[:journal] == journal_key && s[:source] == source_name
      milestones = s[:milestones]
      # returns the first milestone that matches the criteria
      hit = milestones.detect{ |m| range.include?(m) }
      notify_subscriber(s[:url], doi, hit) if hit
    end
  end

  def self.notify_subscriber(url, doi, milestone)
    Faraday.get(url, doi: doi, milestone: milestone)
  end
end