class CslImport < Import
  def parse_data(result)
    mem = member.split(",") if member.present?

    Array(result).map do |item|
      doi = item.fetch("DOI", nil)
      canonical_url = item.fetch("URL", nil)

      date_parts = item.fetch("issued", {}).fetch("date-parts", [])[0]
      year, month, day = date_parts[0], date_parts[1], date_parts[2]

      title = item.fetch("title", nil)
      name = Array(mem).first
      if name
        publisher = Publisher.where(name: name).first
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
        canonical_url: canonical_url,
        title: title,
        year: year.to_i,
        month: month.to_i,
        day: day.to_i,
        publisher_id: publisher_id,
        work_type_id: work_type_id,
        tracked: true,
        csl: csl }
    end
  end
end
