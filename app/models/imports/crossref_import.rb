class CrossrefImport < Import

  TYPES_WITH_TITLE = %w(journal-article
                        proceedings-article
                        dissertation
                        standard
                        report
                        book
                        monograph
                        edited-book
                        reference-book
                        dataset)

  def initialize(options = {})
    from_update_date = options.fetch(:from_update_date, nil)
    until_update_date = options.fetch(:until_update_date, nil)
    from_pub_date = options.fetch(:from_pub_date, nil)
    until_pub_date = options.fetch(:until_pub_date, nil)
    type = options.fetch(:type, nil)
    @member = options.fetch(:member, nil)
    @member = @member.to_s.split(",") if @member.present?
    issn = options.fetch(:issn, nil)
    sample = options.fetch(:sample, 0)
    @sample = sample.to_i

    from_update_date = (Time.zone.now.to_date - 1.day).iso8601 if from_update_date.blank?
    until_update_date = Time.zone.now.to_date.iso8601 if until_update_date.blank?
    until_pub_date = Time.zone.now.to_date.iso8601 if until_pub_date.blank?

    @filter = "from-update-date:#{from_update_date}"
    @filter += ",until-update-date:#{until_update_date}"
    @filter += ",until-pub-date:#{until_pub_date}"
    @filter += ",from-pub-date:#{from_pub_date}" if from_pub_date
    @filter += ",type:#{type}" if type
    @filter += ",issn:#{issn}" if issn

    @filter += @member.reduce("") { |sum, m| sum + ",member:#{m}" } if @member.present?
  end

  def total_results
    result = get_result(query_url(offset = 0, rows = 0)) || {}
    result.fetch('message', {}).fetch('total-results', 0)
  end

  def query_url(offset = 0, rows = 1000)
    url = "http://api.crossref.org/works?"
    if @sample > 0
      params = { filter: @filter, sample: @sample }
    else
      params = { filter: @filter, offset: offset, rows: rows }
    end
    url + params.to_query
  end

  def get_data(offset = 0, options={})
    get_result(query_url(offset), options)
  end

  def parse_data(result)
    # return early if an error occured
    return [] unless result && result.fetch('status', nil) == "ok"

    items = result.fetch('message', {}).fetch('items', nil)
    Array(items).map do |item|
      doi = item.fetch("DOI", nil)
      canonical_url = item.fetch("URL", nil)
      date_parts = item.fetch("issued", {}).fetch("date-parts", []).first
      year, month, day = date_parts[0], date_parts[1], date_parts[2]

      title = case item["title"].length
              when 0 then nil
              when 1 then item["title"][0]
              else item["title"][0].presence || item["title"][1]
              end

      if title.blank? && !TYPES_WITH_TITLE.include?(item["type"])
        title = item["container-title"][0].presence || "No title"
      end
      publisher_id = item.fetch("member", nil)
      publisher_id = publisher_id[30..-1].to_i if publisher_id

      type = item.fetch("type", nil)
      type = CROSSREF_TYPE_TRANSLATIONS[type] if type
      work_type_id = WorkType.where(name: type).pluck(:id).first

      csl = {
        "issued" => item.fetch("issued", {}),
        "author" => item.fetch("author", []),
        "container-title" => item.fetch("container-title", [])[0],
        "page" => item.fetch("page", nil),
        "issue" => item.fetch("issue", nil),
        "title" => title,
        "type" => type,
        "DOI" => doi,
        "URL" => canonical_url,
        "publisher" => item.fetch("publisher", nil),
        "volume" => item.fetch("volume", nil)
      }

      { doi: doi,
        title: title,
        year: year,
        month: month,
        day: day,
        publisher_id: publisher_id,
        work_type_id: work_type_id,
        csl: csl }
    end
  end
end
