# encoding: UTF-8

module Dateable
  extend ActiveSupport::Concern

  included do

    # Array of hashes in format [{ month: 12, year: 2013 },{ month: 1, year: 2014 }]
    # Provide starting month and year as input, otherwise defaults to this month
    # PMC is only providing stats until the previous month
    def date_range(options = {})
      end_date = Date.today
      end_date -= 1.month if self.class.name == 'Pmc'

      return [{ month: end_date.month, year: end_date.year }] unless options[:month] && options[:year]

      start_date = Date.new(options[:year].to_i, options[:month].to_i, 1)
      start_date = end_date if start_date > end_date
      (start_date..end_date).map { |date| { month: date.month, year: date.year } }.uniq
    rescue ArgumentError
      [{ month: end_date.month, year: end_date.year }]
    end

    def get_date_parts(iso8601_time)
      return nil if iso8601_time.nil?

      year = iso8601_time[0..3].to_i
      month = iso8601_time[5..6].to_i
      day = iso8601_time[8..9].to_i
      { 'date-parts' => [[year, month, day]] }
    end

    def get_date_parts_from_parts(year, month = nil, day = nil)
      { 'date-parts' => [[year, month, day].reject(&:blank?)] }
    end
  end
end
