class DoiImport < Import
  def total_results
    content = File.open(filepath, 'r') { |f| f.read }
    content.split("\n").length
  rescue Errno::ENOENT
    0
  end

  def get_data(options={})
    offset = options[:offset].to_i
    rows = (options[:rows] || 1000).to_i
    return [] if filepath.nil?

    content = File.open(filepath, 'r') { |f| f.read }
    content = content.split("\n")[offset...offset + rows]

    items = content.map do |line|
      line = ActiveSupport::Multibyte::Unicode.tidy_bytes(line)
      doi = line.chomp
      next unless doi.present?

      { "doi" => doi }
    end

    { "items" => items }
  end

  def parse_data(result)
    items = result.fetch('items', nil)

    Array(items).map do |item|
      doi = item.fetch("doi", nil)

      registration_agency = get_doi_ra(doi)
      metadata = get_metadata(doi, registration_agency)

      if metadata[:error]
        nil
      else
        title = metadata.fetch("title", nil)
        type = metadata.fetch("type", nil)
        work_type_id = WorkType.where(name: type).pluck(:id).first

        date_parts = metadata.fetch("issued", {}).fetch("date-parts", [])[0]
        year, month, day = date_parts[0], date_parts[1], date_parts[2]

        csl = {
          "issued" => metadata.fetch("issued", {}),
          "author" => metadata.fetch("author", []),
          "container-title" => metadata.fetch("container-title", nil),
          "page" => metadata.fetch("page", nil),
          "issue" => metadata.fetch("issue", nil),
          "title" => title,
          "type" => type,
          "DOI" => doi,
          "publisher" => metadata.fetch("publisher", nil),
          "volume" => metadata.fetch("volume", nil)
        }

        { doi: doi,
          title: title,
          year: year,
          month: month,
          day: day,
          publisher_id: metadata.fetch("publisher_id", nil),
          work_type_id: work_type_id,
          registration_agency: registration_agency,
          tracked: true,
          csl: csl }
      end
    end
  end
end
