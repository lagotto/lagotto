class CrossRef < Agent
  def get_query_url(options={})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return {} unless work.present? && work.doi.present? && registration_agencies.include?(work.registration_agency)

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

  def parse_data(result, options={})
    return [result] if result[:error]

    work = Work.where(id: options.fetch(:work_id, nil)).first
    return [{ error: "Resource not found.", status: 404 }] unless work.present?

    related_works = get_related_works(result, work)

    if work.publisher
      total = related_works.length
    else
      total = (result.deep_fetch('crossref_result', 'query_result', 'body', 'query', 'fl_count') { 0 }).to_i
    end

    { works: related_works,
      events: [{
        source_id: name,
        work_id: work.pid,
        total: total,
        extra: get_extra(result) }] }
  end

  def get_related_works(result, work)
    related_works = result.deep_fetch('crossref_result', 'query_result', 'body', 'forward_link') { nil }
    if related_works.is_a?(Hash) && related_works['journal_cite']
      related_works = [related_works]
    elsif related_works.is_a?(Hash)
      related_works = nil
    end

    Array(related_works).map do |item|
      item = item.fetch("journal_cite", {})
      if item.empty?
        nil
      else
        doi = item.fetch("doi", nil)
        metadata = get_metadata(doi, "crossref")

        if metadata[:error]
          nil
        else
          { "pid" => doi_as_url(doi),
            "issued" => metadata.fetch("issued", {}),
            "author" => metadata.fetch("author", []),
            "container-title" => metadata.fetch("container-title", nil),
            "volume" => metadata.fetch("volume", nil),
            "issue" => metadata.fetch("issue", nil),
            "page" => metadata.fetch("page", nil),
            "title" => metadata.fetch("title", nil),
            "DOI" => doi,
            "type" => metadata.fetch("type", nil),
            "tracked" => tracked,
            "publisher_id" => metadata.fetch("publisher_id", nil),
            "registration_agency" => "crossref",
            "related_works" => [{ "pid" => work.pid,
                                  "source_id" => name,
                                  "relation_type_id" => "cites" }] }
        end
      end
    end.compact
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
        url = doi_as_url(item.fetch('doi', nil))

        { event: item,
          event_url: url,

          # the rest is CSL (citation style language)
          event_csl: {
            'author' => get_authors(item.fetch('contributors', {}).fetch('contributor', [])),
            'title' => String(item.fetch('article_title') { '' }).titleize,
            'container-title' => item.fetch('journal_title') { '' },
            'issued' => get_date_parts_from_parts(item['year']),
            'url' => url,
            'type' => 'article-journal' }
        }
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
