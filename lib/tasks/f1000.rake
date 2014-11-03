require 'date'

namespace :f1000 do

  desc "Bulk-import F1000Prime data"
  task :update => :environment do
    # silently exit if f1000 source is not available
    source = Source.active.where(name: "f1000").first
    exit if source.nil?

    unless source.get_feed
      puts "An error occured while saving the F1000 feed"
      exit
    else
      puts "The F1000 feed has been saved."
    end
    unless source.parse_feed
      puts "An error occured while parsing the F1000 feed"
      exit
    else
      puts "The F1000 feed has been parsed."
    end
  end
end
