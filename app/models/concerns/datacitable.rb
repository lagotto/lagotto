module Datacitable
  extend ActiveSupport::Concern

  included do
    def parse_data(result, _work, options={})
      result = { error: "No hash returned." } unless result.is_a?(Hash)
      return result if result[:error]

      items = result.fetch('response', {}).fetch('docs', nil)

      { works: get_works(items),
        events: get_events(items) }
    end

    # override this method
    def get_works(items)
      []
    end

    # override this method
    def get_events(items)
      []
    end
  end
end
