require 'date'
require 'addressable/uri'

namespace :pmc do
  desc "Bulk-import PMC usage stats by month and journal"
  task :update => :environment do |t, args|

    # silently exit if pmc source is not available
    source = Source.visible.find_by_name("pmc")
    exit if source.nil?

    dates = source.date_range(month: ENV['MONTH'], year: ENV['YEAR'])

    dates.each do |date|
      journals_with_errors = source.get_feed(date[:month], date[:year])
      if journals_with_errors.empty?
        puts "PMC Usage stats for month #{date[:month]} and year #{date[:year]} have been saved"
      else
        puts "PMC Usage stats for month #{date[:month]} and year #{date[:year]} could not be saved for #{journals_with_errors.join(', ')}"
        exit
      end
      journals_with_errors = source.parse_feed(date[:month], date[:year])
      if journals_with_errors.empty?
        puts "PMC Usage stats for month #{date[:month]} and year #{date[:year]} have been parsed"
      else
        puts "PMC Usage stats for month #{date[:month]} and year #{date[:year]} could not be parsed for #{journals_with_errors.join(', ')}"
      end
    end
  end
end
