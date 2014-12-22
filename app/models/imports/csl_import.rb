class CslImport < Import
  def initialize(options = {})
    @filepath = options.fetch(:filepath, nil)
    @member = options.fetch(:member, nil).to_s.split(",")
  end

  def total_results
    begin
      content = File.open(@filepath, 'r') { |f| f.read }
      JSON.parse(content).length
    rescue Errno::ENOENT, JSON::ParserError
      0
    end
  end

  def get_data(offset = 0, rows = 1000)
    content = File.open(@filepath, 'r') { |f| f.read }
    json = JSON.parse(content)
    json[offset...offset + rows]
  end

  def parse_data(result)
    Array(result).map do |item|
      doi = item.fetch("DOI", nil)
      canonical_url = item.fetch("URL", nil)

      date_parts = item.fetch("issued", {}).fetch("date-parts", [])[0]
      year, month, day = date_parts[0], date_parts[1], date_parts[2]

      title = item.fetch("title", nil)
      member_id = @member.first
      if member_id
        publisher = Publisher.where(member_id: member_id).first
      else
        publisher = item.fetch("publisher", nil)
      end

      type = item.fetch("type", nil)
      work_type_id = WorkType.where(name: type).pluck(:id).first

      csl = {
        "issued" => item.fetch("issued", []),
        "author" => item.fetch("author", []),
        "container-title" => item.fetch("container-title", [])[0],
        "page" => item.fetch("page", nil),
        "issue" => item.fetch("issue", nil),
        "title" => title,
        "type" => type,
        "DOI" => doi,
        "URL" => canonical_url,
        "publisher" => publisher,
        "volume" => item.fetch("volume", nil)
      }

      { doi: doi,
        title: title,
        year: year.to_i,
        month: month.to_i,
        day: day.to_i,
        publisher_id: member_id,
        work_type_id: work_type_id,
        csl: csl }
    end
  end
end
