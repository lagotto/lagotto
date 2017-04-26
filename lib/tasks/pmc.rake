require 'date'
require 'addressable/uri'

namespace :pmc do
  desc "Bulk-import PMC usage stats by month and journal"
  task :update, [:is_precise] => :environment do
    # silently exit if pmc source is not available
    source = Source.visible.where(name: "pmc").first
    exit if source.nil?

    date = Time.zone.now - 1.month
    ENV['MONTH'] ||= date.month.to_s
    ENV['YEAR'] ||= date.year.to_s

    if ENV['IS_PRECISE'] == 1
      is_precise = true
    else
      is_precise = false
    end

    publisher_ids = source.process_feed(ENV['MONTH'], ENV['YEAR'], options={}, is_precise)

    if publisher_ids.length > 0
      publisher_ids.each do |publisher_id|
        publisher = Publisher.where(member_id: publisher_id).first
        puts "Import of PMC usage stats queued for publisher #{publisher.title}, starting month #{ENV['MONTH']} and year #{ENV['YEAR']}"
      end
    else
      puts "No publisher for PMC usage stats found."
    end
  end
end
