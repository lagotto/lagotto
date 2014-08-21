class MemberList
  # include HTTP request helpers
  include Networkable

  attr_accessor :query, :offset, :per_page, :publishers, :total_entries

  def self.per_page
    15
  end

  def initialize(attributes = {})
    @query = attributes.fetch(:query, "")
    @offset = attributes.fetch(:offset, 0)
    @per_page = attributes.fetch(:per_page, 15)

    @publishers = get_publishers
  end

  def get_publishers
    result = get_data
    result = parse_data(result)
  end

  def query_url
    url = "http://api.crossref.org/members?"
    params = { query: query, offset: offset, rows: per_page }
    url + params.to_query
  end

  def get_data(options={})
    result = get_result(query_url, options)

    # extend hash fetch method to nested hashes
    result.extend Hashie::Extensions::DeepFetch
  end

  def parse_data(result)
    # return early if an error occured
    return result if result["status"] != "ok"

    # total number of results for pagination
    @total_entries = result.deep_fetch('message', 'total-results') { 0 }

    items = result['message'] && result.deep_fetch('message', 'items') { nil }

    # return array of unsaved ActiveRecord objects
    Array(items).map do |item|
      Publisher.new do |publisher|
        publisher.name = item["primary-name"]
        publisher.crossref_id = item["id"]
        publisher.prefixes = item["prefixes"]
        publisher.other_names = item["names"]
      end
    end
  end

  def to_param  # overridden, use crossref_id instead of id
    crossref_id
  end

  def persisted?
    false
  end
end
