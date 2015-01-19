namespace :sidekiq do
  desc "Start sidekiq"
  task :start => :environment do
    process = SidekiqProcess.new
    puts process.start
  end

  desc "Stop sidekiq"
  task :stop => :environment do
    process = SidekiqProcess.new
    puts process.stop
  end

  desc "Quiet sidekiq"
  task :quiet => :environment do
    process = SidekiqProcess.new
    puts process.quiet
  end

  desc "Monitor sidekiq"
  task :monitor => :environment do
    process = SidekiqProcess.new
    puts process.monitor
  end
end
