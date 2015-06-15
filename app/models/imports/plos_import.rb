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
    date_range = "publication_date:[#{from_pub_date}T00:00:00Z TO #{until_pub_date}T23:59:59Z]"
    params = { q: "*:*",
               start: offset,
               rows: rows,
               fl: "id,publication_date,title_display,cross_published_journal_name,author_display,volume,issue,elocation_id",
               fq: "+#{date_range}+doc_type:full",
               wt: "json" }
    url + params.to_query
  end

  def get_data(options={})
    offset = options[:offset].to_i
    get_result(query_url(offset), options)
  end

  def parse_data(result)
    if !result.is_a?(Hash)
      # make sure we have a hash
      result = { 'response' => result }
    elsif result[:status] == 404 || result[:error]
      result = { 'response' => {} }
    end

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
        "publisher" => "Public Library of Science (PLOS)",
        "volume" => item.fetch("volume", nil),
        "issue" => item.fetch("issue", nil),
        "page" => item.fetch("elocation_id", nil)
      }

      { doi: doi,
        title: title,
        year: year,
        month: month,
        day: day,
        publisher_id: member_id,
        work_type_id: work_type_id,
        tracked: true,
        csl: csl }
    end
  end
end
