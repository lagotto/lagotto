namespace :sidekiq do
  desc "Monitor sidekiq"
  task :monitor => :environment do
    status = Status.new
    monitor = status.process_monitor
    puts monitor[:message]
  end
end
