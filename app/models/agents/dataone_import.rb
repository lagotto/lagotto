class DataoneImport < Agent
  # include common methods for Import
  include Importable

  def get_query_url(options={})
    offset = options[:offset].to_i
    rows = options[:rows].presence || job_batch_size
    from_date = options[:from_date].presence || (Time.zone.now.to_date - 1.day).iso8601
    until_date = options[:until_date].presence || Time.zone.now.to_date.iso8601

    date_range = "dateModified:[#{from_date}T00:00:00Z TO #{until_date}T23:59:59Z]"
    params = { q: [date_range, "formatType:METADATA"].compact.join("+"),
               start: offset,
               rows: rows,
               fl: "id,title,author,datePublished,authoritativeMN,dateModified",
               wt: "json" }
    url + params.to_query
  end

  def get_works(result)
    # return early if an error occured
    return [] unless result.is_a?(Hash) && result.fetch("response", nil)

    items = result.fetch('response', {}).fetch('docs', nil)
    Array(items).map do |item|
      id = item.fetch("id", nil)
      doi = get_doi_from_id(id)
      ark = id.starts_with?("ark:/") ? id.split("/")[0..2].join("/") : nil
      if doi.present?
        url = nil
      elsif id.starts_with?("http://")
        url = get_normalized_url(id)
      else
        url = nil
      end

      if doi.nil? && ark.nil? && url.nil?
        Notification.where(message: "No known identifier found in #{id}").where(unresolved: true).first_or_create(
          exception: "",
          class_name: "ActiveModel::MissingAttributeError")
      end

      publication_date = get_iso8601_from_time(item.fetch("datePublished", nil))
      date_parts = get_date_parts(publication_date)
      year, month, day = date_parts.fetch("date-parts", []).first

      publisher_symbol = item.fetch("authoritativeMN", nil)
      publisher_id = publisher_symbol.present? ? publisher_symbol.to_i(36) : nil

      { "author" => get_authors([item.fetch("author", nil)]),
        "container-title" => nil,
        "title" => item.fetch("title", nil),
        "issued" => date_parts,
        "DOI" => doi,
        "URL" => url,
        "ark" => ark,
        "publisher_id" => publisher_id,
        "tracked" => tracked,
        "type" => "dataset" }
    end
  end

  def config_fields
    [:url]
  end

  def url
    "https://cn.dataone.org/cn/v1/query/solr/?"
  end
end
