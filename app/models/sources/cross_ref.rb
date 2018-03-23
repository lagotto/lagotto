class CrossRef < Source
  def get_query_url(work)
    return {} unless work.doi.present? && registration_agencies.include?(work.registration_agency)

    if work.publisher_id.present?
      # check that we have publisher-specific configuration
      pc = publisher_config(work.publisher_id)
      fail ArgumentError, "CrossRef username or password is missing." if pc.username.nil? || pc.password.nil?

      url % { :username => pc.username, :password => pc.password, :doi => work.doi_escaped }
    else
      fail ArgumentError, "CrossRef OpenURL username is missing." if openurl_username.nil?

      openurl % { :openurl_username => openurl_username, :doi => work.doi_escaped }
    end
  end

  def request_options
    { content_type: 'xml' }
  end

  def parse_data(result, work, options={})
    return result if result[:error]

    if work.publisher
      total = related_works_count(result)
    else
      total = (result.deep_fetch('crossref_result', 'query_result', 'body', 'query', 'fl_count') { 0 }).to_i
    end

    { events: {
        source: name,
        work: work.pid,
        total: total,
        extra: get_extra(result) } }
  end

  def related_works_count(result)
    related_works = result.deep_fetch('crossref_result', 'query_result', 'body', 'forward_link') { nil }
    if related_works.is_a?(Hash) && related_works['journal_cite']
      related_works = [related_works]
    elsif related_works.is_a?(Hash)
      related_works = nil
    end
    # only count journal citations
    related_works.nil? ? 0 : related_works.select { |w| w['journal_cite'] }.size
  end

  def get_extra(result)
    extra = result.deep_fetch('crossref_result', 'query_result', 'body', 'forward_link') { nil }
    if extra.is_a?(Hash) && extra['journal_cite']
      extra = [extra]
    elsif extra.is_a?(Hash)
      extra = nil
    end

    Array(extra).map do |item|
      item = item.fetch('journal_cite') { {} }
      if item.empty?
        nil
      else
        url = get_url_from_doi(item.fetch('doi', nil))
        { event_url: url }
      end
    end.compact
  end

  def get_authors(contributors)
    contributors = [contributors] if contributors.is_a?(Hash)
    contributors.map do |contributor|
      { 'family' => String(contributor['surname']).titleize,
        'given' => String(contributor['given_name']).titleize }
    end
  end

  def config_fields
    [:url, :openurl, :username, :password, :openurl_username]
  end

  def url
    "http://doi.crossref.org/servlet/getForwardLinks?usr=%{username}&pwd=%{password}&doi=%{doi}"
  end

  def openurl
    "http://www.crossref.org/openurl/?pid=%{openurl_username}&id=doi:%{doi}&noredirect=true"
  end

  def timeout
    config.timeout || 120
  end

  def by_publisher?
    true
  end

  def registration_agencies
    ["crossref"]
  end
end
