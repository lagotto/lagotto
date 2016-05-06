class BmcFulltext < Agent
  def get_query_url(options = {})
    query_string = get_query_string(options)
    return {} unless query_string.present?

    url % { query_string: query_string }
  end

  def get_query_string(options = {})
    # don't query if work is BMC article
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return nil if work.nil? || work.doi =~ /^10.1186/ || !registration_agencies.include?(work.registration_agency && work.registration_agency.name)

    work.doi.presence || work.canonical_url.presence
  end

  def parse_data(result, options={})
    return [result] if result[:error]
    return [] if result["entries"].nil?
    super(result, options)
  end

  def get_relations_with_related_works(result, work)
    result.fetch("entries", []).map do |item|
      # workaround since the "doi" attribute is sometimes empty
      doi = "10.1186/#{item.fetch("arxId")}"
      author = Nokogiri::HTML::fragment(item.fetch("authorNames", ""))
      title = Nokogiri::HTML::fragment(item.fetch("bibliograhyTitle", ""))
      container_title = Nokogiri::HTML::fragment(item.fetch("longCitation", ""))

      subj_id = doi_as_url(doi)

      { prefix: work.prefix,
        relation: { "subj_id" => subj_id,
                    "obj_id" => work.pid,
                    "relation_type_id" => "cites",
                    "source_id" => name },
        subj: { "pid" => subj_id,
                "author" => get_authors(author.at_css("span").text.strip.split(/(?:,|and)/), reversed: true),
                "title" => title.at_css("p").text,
                "container-title" => container_title.at_css("em").text,
                "issued" => get_iso8601_from_time(item.fetch("published Date", nil)),
                "DOI" => doi,
                "type" => "article-journal",
                "tracked" => tracked,
                "registration_agency_id" => "crossref" } }
    end
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    "http://www.biomedcentral.com/search/results?terms=%{query_string}&format=json"
  end

  def events_url
    "http://www.biomedcentral.com/search/results?terms=%{query_string}"
  end

  def registration_agencies
    ["datacite", "dataone","cdl", "github", "bitbucket"]
  end

  def tracked
    config.tracked || true
  end
end
