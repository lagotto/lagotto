# encoding: UTF-8

namespace :cache do

  desc "Update cached API responses for admin dashboard"
  task :update => :environment do
    StatusCacheJob.perform_now
    puts "Cache update for status page has been queued."

    Source.visible.each do |source|
      CacheJob.perform_now(source)
      puts "Cache update for source #{source.display_name} has been queued."
    end

    Publisher.all.each do |publisher|
      CacheJob.perform_now(publisher)
      puts "Cache update for publisher #{publisher.title} has been queued."
    end
  end

  desc "Expire all API cache keys"
  task :expire => :environment do
    ApiCacheKey.expire_all
    puts "Expired all API cache keys"
  end

  task :default => :update

end
