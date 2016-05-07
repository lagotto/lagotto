class CrossRef < Agent
  def get_query_url(options={})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return {} unless work.present? && work.doi.present? && registration_agencies.include?(work.registration_agency && work.registration_agency.name)

    if work.publisher.present?
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

    related_works = result.deep_fetch('crossref_result', 'query_result', 'body', 'forward_link') { nil }
    if related_works.is_a?(Hash) && related_works['journal_cite']
      related_works = [related_works]
    elsif related_works.is_a?(Hash)
      related_works = nil
    end

    if work.publisher_id.present?
      get_relations_with_related_works(related_works, work)
    else
      relations = []
      total = (result.deep_fetch('crossref_result', 'query_result', 'body', 'query', 'fl_count') { 0 }).to_i

      if total > 0
        relations << { relation: { "subj_id" => "https://crossref.org",
                                   "obj_id" => work.pid,
                                   "relation_type_id" => "cites",
                                   "total" => total,
                                   "source_id" => source_id },
                       subj: { "pid"=>"https://crossref.org",
                               "URL"=>"https://crossref.org",
                               "title"=>"Crossref",
                               "type"=>"webpage",
                               "issued"=>"2012-05-15T16:40:23Z" }}
      end

      relations
    end
  end

  def get_relations_with_related_works(result, work)
    Array(result).map do |item|
      item = item.fetch("journal_cite", {})
      if item.empty?
        nil
      else
        doi = item.fetch("doi", nil)
        metadata = get_metadata(doi, "crossref")

        if metadata[:error]
          nil
        else
          author = metadata.fetch("author", []).map { |a| a.except("affiliation") }
          subj = { "pid" => doi_as_url(doi),
                   "author" => author,
                   "title" => metadata.fetch("title", nil),
                   "container-title" => metadata.fetch("container-title", nil),
                   "issued" => metadata.fetch("issued", {}),
                   "volume" => metadata.fetch("volume", nil),
                   "issue" => metadata.fetch("issue", nil),
                   "page" => metadata.fetch("page", nil),
                   "DOI" => doi,
                   "type" => metadata.fetch("type", nil),
                   "tracked" => tracked,
                   "publisher_id" => metadata.fetch("publisher_id", nil),
                   "registration_agency_id" => "crossref" }

          { prefix: work.prefix,
            relation: { "subj_id" => subj["pid"],
                        "obj_id" => work.pid,
                        "relation_type_id" => "cites",
                        "source_id" => source_id,
                        "publisher_id" => subj["publisher_id"] },
            subj: subj }
        end
      end
    end.compact
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
