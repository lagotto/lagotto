class CrossRef < Source
  def get_query_url(work)
    return {} unless work.doi.present?

    if work.publisher_id.present?
      # check that we have publisher-specific configuration
      pc = publisher_config(work.publisher_id)
      return { error: "CrossRef username or password is missing." } if pc.username.nil? || pc.password.nil?

      url % { :username => pc.username, :password => pc.password, :doi => work.doi_escaped }
    else
      return { error: "CrossRef OpenURL username is missing." } if openurl_username.nil?

      openurl % { :openurl_username => openurl_username, :doi => work.doi_escaped }
    end
  end

  def request_options
    { content_type: 'xml' }
  end

  def parse_data(result, work, options={})
    return result if result[:error]

    related_works = get_related_works(result, work)

    if work.publisher
      total = related_works.length
    else
      total = (result.deep_fetch('crossref_result', 'query_result', 'body', 'query', 'fl_count') { 0 }).to_i
    end

    { works: related_works,
      metrics: {
        source: name,
        work: work.pid,
        total: total } }
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

        { "author" => get_authors(item.fetch('contributors', {}).fetch('contributor', [])),
          "title" => String(item.fetch("article_title", "")).titleize,
          "container-title" => item.fetch("journal_title", nil),
          "issued" => get_date_parts_from_parts(item.fetch("year", nil)),
          "DOI" => doi,
          "URL" => get_url_from_doi(doi),
          "volume" => item.fetch("volume", nil),
          "issue" => item.fetch("issue", nil),
          "page" => item.fetch("first_page", nil),
          "type" => "article-journal",
          "related_works" => [{ "related_work" => work.pid,
                                "source" => name,
                                "relation_type" => "cites" }] }
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

  def workers
    config.workers || 10
  end

  def by_publisher?
    true
  end
end
