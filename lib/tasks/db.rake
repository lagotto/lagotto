namespace :db do
  namespace :works do
    desc "Delete works"
    task :delete => :environment do
      if ENV['PUBLISHER_ID'].blank?
        puts "Please use PUBLISHER_ID environment variable. No work deleted."
        exit
      end

      if ENV['SOURCE_ID'].blank?
        puts "Please use SOURCE_ID environment variable. No work deleted."
        exit
      end

      DeleteWorkJob.perform_later(publisher_id: ENV['PUBLISHER_ID'], source_id: ENV['SOURCE_ID'])

      if ENV['PUBLISHER_ID'] == "all" && ENV['SOURCE_ID'] == "all"
        puts "Started deleting all works in the background..."
      elsif ENV['PUBLISHER_ID'] == "all"
        puts "Started deleting all works for source #{ENV['SOURCE_ID']} in the background..."
      elsif ENV['SOURCE_ID'] == "all"
        puts "Started deleting all works from publisher #{ENV['PUBLISHER_ID']} in the background..."
      else
        puts "Started deleting all works from publisher #{ENV['PUBLISHER_ID']} for source #{ENV['SOURCE_ID']} in the background..."
      end
    end
  end

  namespace :events do

    desc "Delete all completed events older than 7 days"
    task :delete => :environment do
      count = Event.where("state = ?", 3).where("created_at < ?", Time.zone.now - 7.days).delete_all
      puts "Deleted #{count} completed events"
    end
  end
end
