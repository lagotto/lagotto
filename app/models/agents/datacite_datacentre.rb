class DataciteDatacentre < Agent
  # include common methods for DataCite
  include Datacitable

  def get_total(options={})
    query_url = get_query_url
    result = get_result(query_url, options)
    result.fetch("facet_counts", {}).fetch("facet_fields", {}).fetch('datacentre_facet', []).length / 2
  end

  def get_query_url(options={})
    params = { q: "*:*",
               start: 0,
               rows: 0,
               facet: 'true',
               'facet.field' => 'datacentre_facet',
               'facet.limit' => -1,
               wt: "json" }
    url +  URI.encode_www_form(params)
  end

  def parse_data(result, options={})
    result = { error: "No hash returned." } unless result.is_a?(Hash)
    return result if result[:error]

    datacentre_facet = result.fetch("facet_counts", {}).fetch("facet_fields", {}).fetch('datacentre_facet', [])
    items = datacentre_facet.values_at(* datacentre_facet.each_index.select {|i| i.even?})

    Array(items).map do |item|
      datacentre_name, datacentre_title = item.split(' - ', 2)

      { message_type: "publisher",
        relation: { "subj_id" => datacentre_name,
                    "source_id" => name },
        subj: { "name" => datacentre_name,
                "title" => datacentre_title,
                "registration_agency_id" => "datacite",
                "active" => true } }
    end
  end

  def cron_line
    config.cron_line || "40 1 * * 1"
  end
end
