class DataciteImport < Import
  # DataCite Solr schema is at https://github.com/datacite/search/blob/master/src/main/resources/schema.xml

  # DataCite resourceTypeGeneral from DataCite metadata schema: http://dx.doi.org/10.5438/0010
  TYPE_TRANSLATIONS = {
    "Audiovisual" => "motion_picture",
    "Collection" => nil,
    "Dataset" => "dataset",
    "Event" => nil,
    "Image" => "graphic",
    "InteractiveResource" => nil,
    "Model" => nil,
    "PhysicalObject" => nil,
    "Service" => nil,
    "Software" => nil,
    "Sound" => "song",
    "Text" => "report",
    "Workflow" => nil,
    "Other" => nil
  }

  def initialize(options = {})
    @from_update_date = options.fetch(:from_update_date, nil)
    @until_update_date = options.fetch(:until_update_date, nil)
    @from_pub_date = options.fetch(:from_pub_date, nil)
    @until_pub_date = options.fetch(:until_pub_date, nil)
    @type = options.fetch(:type, nil)
    @member = options.fetch(:member, nil)
    @member = @member.to_s.split(",") if @member.present?

    @from_update_date = (Time.zone.now.to_date - 1.day).iso8601 if @from_update_date.blank?
    @until_update_date = Time.zone.now.to_date.iso8601 if @until_update_date.blank?
    @from_pub_date = "1650-01-01" if @from_pub_date.blank?
    @until_pub_date = Time.zone.now.to_date.iso8601 if @until_pub_date.blank?
  end

  def total_results
    result = get_result(query_url(offset = 0, rows = 0)) || {}
    result.fetch('response', {}).fetch('numFound', 0)
  end

  def query_url(offset = 0, rows = 1000)
    url = "http://search.datacite.org/api?"
    updated = "updated:[#{@from_update_date}T00:00:00Z TO #{@until_update_date}T23:59:59Z]"
    publication_year = "publicationYear:[#{Date.parse(@from_pub_date).year} TO #{Date.parse(@until_pub_date).year}]"
    resource_type_general = @type.nil? ? nil : "resourceTypeGeneral:#{@type}"
    datacentre_symbol = @member.blank? ? nil : "datacentre_symbol:" + @member.join("+OR+")
    has_metadata = "has_metadata:true"
    is_active = "is_active:true"
    fq_list = [updated, publication_year, resource_type_general, datacentre_symbol, has_metadata, is_active]

    params = { q: "*:*",
               start: offset,
               rows: rows,
               fl: "doi,creator,title,publisher,publicationYear,resourceTypeGeneral,datacentre,datacentre_symbol,prefix,relatedIdentifier,updated",
               fq: fq_list.compact,
               wt: "json" }
    url +  URI.encode_www_form(params)
  end

  def get_data(offset = 0, options={})
    get_result(query_url(offset), options)
  end

  def parse_data(result)
    # return early if an error occured
    return [] unless result && result.fetch('responseHeader', {}).fetch('status', nil)

    items = result.fetch('response', {}).fetch('docs', nil)
    Array(items).map do |item|
      doi = item.fetch("doi", nil)
      year = item.fetch("publicationYear", nil).to_i
      title = item.fetch("title", []).first

      publisher_title = item.fetch("publisher", nil)
      publisher_name = item.fetch("datacentre_symbol", nil)
      if publisher_name
        member_id = publisher_name.to_i(36)
        publisher = Publisher.where(member_id: member_id).first_or_create(
          title: publisher_title,
          name: publisher_name,
          prefixes: Array(item.fetch("prefix", nil)),
          other_names: Array(item.fetch("datacentre", nil)),
          service: "datacite")
      else
        member_id = nil
      end

      type = item.fetch("resourceTypeGeneral", nil)
      type = TYPE_TRANSLATIONS[type] if type
      work_type_id = WorkType.where(name: type).pluck(:id).first

      csl = {
        "issued" => { "date-parts" => [[year]] },
        "author" => get_authors(item.fetch("creator", [])),
        "container-title" => nil,
        "title" => title,
        "type" => type,
        "DOI" => doi,
        "publisher" => publisher_title
      }

      { doi: doi,
        title: title,
        year: year,
        month: nil,
        day: nil,
        publisher_id: member_id,
        work_type_id: work_type_id,
        csl: csl }
    end
  end
end
