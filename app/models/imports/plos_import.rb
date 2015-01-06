class PlosImport < Import
  def initialize(options = {})
    @from_pub_date = options.fetch(:from_pub_date, nil)
    @until_pub_date = options.fetch(:until_pub_date, nil)

    @from_pub_date = (Time.zone.now.to_date - 1.day).iso8601 if @from_pub_date.blank?
    @until_pub_date = Time.zone.now.to_date.iso8601 if @until_pub_date.blank?
  end

  def total_results
    result = get_result(query_url(offset = 0, rows = 0)) || {}
    result.fetch("response", {}).fetch("numFound", 0)
  end

  def query_url(offset = 0, rows = 1000)
    url = "http://api.plos.org/search?"
    date_range = "publication_date:[#{@from_pub_date}T00:00:00Z TO #{@until_pub_date}T23:59:59Z]"
    params = { q: "*:*",
               start: offset,
               rows: rows,
               fl: "id,publication_date,title_display,cross_published_journal_name,author_display",
               fq: "+#{date_range}+doc_type:full",
               wt: "json" }
    url + params.to_query
  end

  def get_data(offset = 0, options={})
    get_result(query_url(offset), options)
  end

  def parse_data(result)
    # return early if an error occured
    return [] unless result && result.fetch("response", nil)

    # fixed values, member_id is PLOS CrossRef member id
    member_id = 340
    type = "article-journal"
    work_type_id = WorkType.where(name: type).pluck(:id).first

    items = result.fetch('response', {}).fetch('docs', nil)
    Array(items).map do |item|
      doi = item.fetch("id", nil)
      publication_date = get_iso8601_from_time(item.fetch("publication_date", nil))
      date_parts = get_date_parts(publication_date)
      year, month, day = date_parts.fetch("date-parts", []).first
      title = item.fetch("title_display", nil)

      csl = {
        "issued" => date_parts,
        "author" => get_authors(item.fetch("author_display", [])),
        "container-title" => item.fetch("cross_published_journal_name", []).first,
        "title" => title,
        "type" => type,
        "DOI" => doi,
        "publisher" => "Public Library of Science (PLOS)"
      }

      { doi: doi,
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
