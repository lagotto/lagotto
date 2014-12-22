class FileImport < Import
  def initialize(options = {})
    @file = options.fetch(:file, nil)
    @member = options.fetch(:member, nil).to_s.split(",")
  end

  def total_results
    @file.length
  end

  def get_data(offset = 0)
    result = get_text(offset)
  end

  def get_text(offset = 0, rows = 500)
    text = @file.slice(offset...(offset + rows))
    items = text.map do |line|
      line = ActiveSupport::Multibyte::Unicode.tidy_bytes(line)
      raw_doi, raw_published_on, raw_title = line.strip.split(" ", 3)
      next if raw_doi.nil?

      doi = get_id_hash(raw_doi.strip).values.first
      if raw_published_on
        # date_parts is an array of non-null integers: [year, month, day]
        # everything else should be nil and thrown away with compact
        date_parts = raw_published_on.split("-")
        date_parts = date_parts.map { |x| x.to_i > 0 ? x.to_i : nil }.compact
      else
        date_parts = []
      end
      title = raw_title ? raw_title.strip.chomp('.') : ""

      { "doi" => doi,
        "issued" => { "date-parts" => [date_parts] },
        "title" => [title],
        "type" => "article-journal",
        "member" => @member.first }
    end

    { "items" => items }
  end

  def parse_data(result)
    items = result.fetch('items', nil)

    Array(items).map do |item|
      doi = item.fetch("doi", nil)
      title = item.fetch("title", []).first
      date_parts = item["issued"]["date-parts"][0]
      year, month, day = date_parts[0], date_parts[1], date_parts[2]
      type = item.fetch("type", nil)
      work_type_id = WorkType.where(name: type).pluck(:id).first
      member_id = item.fetch("member", nil)
      publisher = Publisher.where(member_id: member_id).first

      csl = {
        "issued" => item.fetch("issued", []),
        "title" => title,
        "type" => type,
        "DOI" => doi,
        "publisher" => publisher
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
