module Reportable
  module ToCsv
    extend ActiveSupport::Concern

    included do
      def headers
        raise NotImplementedError, "Must override :headers in the including class to conform to #{ReportingToCsv.name}"
      end

      def line_items
        raise NotImplementedError, "Must override :line_items in the including class to conform to #{ReportingToCsv.name}"
      end

      def to_csv
        CSV.generate do |csv|
          csv << headers
          line_items.each { |line_item|
            csv << headers.map{ |header| line_item.field(header) }
          }
        end
      end
    end
  end
end
