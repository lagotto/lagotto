require 'csv'

module Reportable
  module ToCsv
    extend ActiveSupport::Concern

    included do
      def headers
        raise NotImplementedError, "Must override :headers in the including class to conform to #{ReportingToCsv.name}"
      end

      def each_line_item(&blk)
        raise NotImplementedError, "Must override each_line_item in the including class to conform to #{ReportingToCsv.name}"
      end

      def to_csv
        CSV.generate do |csv|
          csv << headers
          each_line_item { |line_item|
            csv << headers.map{ |header| line_item.field(header) }
          }
        end
      end
    end
  end
end
