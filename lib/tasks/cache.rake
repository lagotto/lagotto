# encoding: UTF-8

namespace :cache do

  desc "Update cached API responses for admin dashboard"
  task :update => :environment do
    status = Status.new
    status.update_cache
    puts "Cache update for status page has been queued."

    sources = Source.visible
    sources.each do |source|
      source.update_cache
      puts "Cache update for source #{source.display_name} has been queued."
    end
  end

  desc "Expire all API cache keys"
  task :expire => :environment do
    ApiCacheKey.expire_all
    puts "Expired all API cache keys"
  end

  task :default => :update

end
