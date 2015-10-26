class SciencetoolboxImport < Import
  def parse_data(result)
    mem = member.split(",") if member.present?

    Array(result).map do |item|
      doi = item.fetch("doi", nil)
      canonical_url = item.fetch("url", nil)

      updated_at = item.fetch("metadata", {}).fetch("updated_at", nil) || item.fetch("metadata", {}).fetch("utc_last_updated", nil)
      date_parts = get_date_parts(updated_at)
      parts = date_parts.fetch("date-parts", [[]]).first
      year, month, day = parts[0], parts[1], parts[2]

      title = item.fetch("description", nil)
      name = Array(mem).first
      if name
        publisher = Publisher.where(name: name).first
      else
        publisher = nil
      end

      type = "dataset" # currently best fit among CSL types
      work_type_id = WorkType.where(name: type).pluck(:id).first

      csl = {
        "issued" => { "issued" => date_parts },
        "author" => nil,
        "container-title" => nil,
        "title" => title,
        "type" => type,
        "DOI" => doi,
        "URL" => canonical_url,
        "publisher" => publisher
      }

      { doi: doi,
        canonical_url: canonical_url,
        title: title,
        year: year,
        month: month,
        day: day,
        publisher_id: publisher.id,
        work_type_id: work_type_id,
        tracked: true,
        csl: csl }
    end
  end
end
