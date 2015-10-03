module Datacitable
  extend ActiveSupport::Concern

  included do
    def parse_data(result, _work, options={})
      result = { error: "No hash returned." } unless result.is_a?(Hash)
      return result if result[:error]

      items = result.fetch('response', {}).fetch('docs', nil)
      works = get_works(items)
      related_works = get_related_works(items)
      events = get_events(items)

      { works: works + related_works,
        events: events }
    end

    def get_works(items)
      Array(items).map do |item|
        year = item.fetch("publicationYear", nil).to_i
        type = item.fetch("resourceTypeGeneral", nil)
        type = DATACITE_TYPE_TRANSLATIONS[type] if type
        publisher_symbol = item.fetch("datacentre_symbol", nil)
        publisher_id = publisher_symbol.to_i(36)

        { "author" => get_authors(item.fetch("creator", []), reversed: true, sep: ", "),
          "container-title" => nil,
          "title" => item.fetch("title", []).first,
          "issued" => { "date-parts" => [[year]] },
          "DOI" => item.fetch("doi", nil),
          "publisher_id" => publisher_id,
          "registration_agency" => "datacite",
          "tracked" => true,
          "type" => type }
      end
    end

    # override this method
    def get_related_works(items)
      []
    end

    # override this method
    def get_events(items)
      []
    end
  end
end
