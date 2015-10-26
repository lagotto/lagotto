namespace :cache do

  desc "Update cached API responses for admin dashboard"
  task :update => :environment do
    StatusCacheJob.perform_later
    puts "Cache update for status page has been queued."

    Source.active.each do |source|
      CacheJob.perform_later(source)
    end
    puts "Cache update for sources has been queued."

    Agent.visible.each do |agent|
      CacheJob.perform_later(agent)
    end
    puts "Cache update for agents has been queued."

    # Publisher.active.each do |publisher|
    #   CacheJob.perform_later(publisher)
    # end
    # puts "Cache update for publishers has been queued."
    #
    # Contributor.all.each do |contributor|
    #   CacheJob.perform_later(contributor)
    # end
    # puts "Cache update for contributors has been queued."
  end

  desc "Expire all API cache keys"
  task :expire => :environment do
    ApiCacheKey.expire_all
    puts "Expired all API cache keys"
  end

  task :default => :update

end
