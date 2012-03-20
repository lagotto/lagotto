
module DOI
  # Format used for validation - we want to store DOIs without
  # the leading "info:doi/"
  FORMAT = %r(\d+\.[^/]+/[^/]+)

  def self.from_uri(doi)
    return nil if doi.nil?
    doi = doi.gsub("%2F", "/")
    if doi.starts_with? "http://dx.doi.org/"
      doi = doi[18..-1]
    end
    if doi.starts_with? "info:doi/"
      doi = doi[9..-1]
    end
    doi
  end

  def self.to_uri(doi, escaped=true)
    return nil if doi.nil?
    unless doi.starts_with? "info:doi"
      doi = "info:doi/" + from_uri(doi)
    end
    doi
  end

  def self.to_url(doi)
    return nil if doi.nil?
    unless doi.starts_with? "http://dx.doi.org/"
      doi = "http://dx.doi.org/" + from_uri(doi)
    end
    doi
  end
end