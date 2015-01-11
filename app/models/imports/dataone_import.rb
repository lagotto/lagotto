class DataoneImport < Import
  def initialize(options = {})
    from_pub_date = options.fetch(:from_pub_date, nil)
    until_pub_date = options.fetch(:until_pub_date, nil)
    from_update_date = options.fetch(:from_update_date, nil)
    until_update_date = options.fetch(:until_update_date, nil)

    @from_pub_date = from_update_date.presence || (Time.zone.now.to_date - 100.years).iso8601
    @until_pub_date = until_pub_date.presence || Time.zone.now.to_date.iso8601
    @from_update_date = from_update_date.presence || (Time.zone.now.to_date - 1.day).iso8601
    @until_update_date = until_update_date.presence || Time.zone.now.to_date.iso8601
    @member = options.fetch(:member, nil).to_s.split(",")
  end

  def total_results
    result = get_result(query_url(offset = 0, rows = 0)) || {}
    result.fetch("response", {}).fetch("numFound", 0)
  end

  def query_url(offset = 0, rows = 1000)
    url = "https://cn.dataone.org/cn/v1/query/solr/?"
    pub_date_range = "datePublished:[#{@from_pub_date}T00:00:00Z TO #{@until_pub_date}T23:59:59Z]"
    update_date_range = "dateModified:[#{@from_update_date}T00:00:00Z TO #{@until_update_date}T23:59:59Z]"
    member_string = @member.present? ? "authoritativeMN:#{@member}" : nil
    params = { q: [pub_date_range, update_date_range, member_string, "formatType:METADATA"].compact.join("+"),
               start: offset,
               rows: rows,
               fl: "id,title,author,datePublished,authoritativeMN,dateModified",
               wt: "json" }
    url + params.to_query
  end

  def get_data(offset = 0, options={})
    get_result(query_url(offset), options)
  end

  def parse_data(result)
    # return early if an error occured
    return [] unless result && result.fetch("response", nil)

    items = result.fetch('response', {}).fetch('docs', nil)
    Array(items).map do |item|
      id = item.fetch("id", nil)
      doi = get_doi_from_url(id)
      url = doi ? nil : get_normalized_url(id)

      publication_date = get_iso8601_from_time(item.fetch("datePublished", nil))
      date_parts = get_date_parts(publication_date)
      year, month, day = date_parts.fetch("date-parts", []).first
      title = item.fetch("title", nil)

      publisher_title = item.fetch("authoritativeMN", nil)
      publisher_name = item.fetch("authoritativeMN", nil)
      if publisher_name
        member_id = publisher_name.to_i(36)
        publisher = Publisher.where(member_id: member_id).first_or_create(
          title: publisher_title,
          name: publisher_name,
          service: "dataone")
      else
        member_id = nil
      end

      type = "dataset"
      work_type_id = WorkType.where(name: type).pluck(:id).first

      csl = {
        "issued" => date_parts,
        "author" => get_authors([item.fetch("author", nil)], ),
        "container-title" => nil,
        "title" => title,
        "type" => type,
        "DOI" => doi,
        "URL" => url,
        "publisher" => publisher
      }

      { doi: doi,
        canonical_url: url,
        title: title,
        year: year,
        month: month,
        day: day,
        publisher_id: member_id,
        work_type_id: work_type_id,
        csl: csl }
    end
  end
end
