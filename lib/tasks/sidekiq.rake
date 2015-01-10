namespace :sidekiq do
  desc "Start sidekiq"
  task :start => :environment do
    status = Status.new
    puts status.process_start
  end

  desc "Stop sidekiq"
  task :stop => :environment do
    status = Status.new
    puts status.process_stop
  end

  desc "Quiet sidekiq"
  task :quiet => :environment do
    status = Status.new
    puts status.process_quiet
  end

  desc "Monitor sidekiq"
  task :monitor => :environment do
    status = Status.new
    puts status.process_monitor
  end
end
