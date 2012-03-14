
namespace :queue do

  task :twitter => :environment do

    #while true
      source = Source.find_by_name("twitter")
      sleep_time = source.queue_jobs
      puts "sleep for #{sleep_time} seconds"
      #sleep(sleep_time)
    #end

  end

  task :twitter_new_article => :environment do

    #while true
      source = Source.find_by_name("twitter")
      sleep_time = source.queue_new_article_jobs
      puts "sleep for #{sleep_time} seconds"
    #  sleep(sleep_time)
    #end
  end

end

