namespace :cron do
  desc 'Hourly cron task'
  task :hourly => :environment do
    Rake::Task["queue:stale"].invoke
    Rake::Task["queue:stale"].reenable

    Rake::Task["cache:update"].invoke
    Rake::Task["cache:update"].reenable

    Rake::Task["sidekiq:monitor"].invoke
    Rake::Task["sidekiq:monitor"].reenable
  end

  desc 'Daily cron task'
  task :daily => :environment do
    Rake::Task["filter:all"].invoke
    Rake::Task["filter:all"].reenable

    Rake::Task["mailer:error_report"].invoke
    Rake::Task["mailer:error_report"].reenable

    Rake::Task["db:api_requests:delete"].invoke
    Rake::Task["db:api_requests:delete"].reenable

    Rake::Task["db:api_responses:delete"].invoke
    Rake::Task["db:api_responses:delete"].reenable

    Rake::Task["db:changes:delete"].invoke
    Rake::Task["db:changes:delete"].reenable

    Rake::Task["db:deposits:delete"].invoke
    Rake::Task["db:deposits:delete"].reenable

    Rake::Task["db:notifications:resolve"].invoke
    Rake::Task["db:notifications:resolve"].reenable
  end

  desc 'Weekly cron task'
  task :weekly => :environment do
    Rake::Task["mailer:status_report"].invoke
    Rake::Task["mailer:status_report"].reenable

    Rake::Task["f1000:update"].invoke
    Rake::Task["f1000:update"].reenable

    Rake::Task["db:notifications:delete"].invoke
    Rake::Task["db:notifications:delete"].reenable
  end

  desc 'Monthly cron task'
  task :monthly => :environment do
    Rake::Task["pmc:update"].invoke
    Rake::Task["pmc:update"].reenable

    Rake::Task["report:all_stats"].invoke
    Rake::Task["report:all_stats"].reenable

    Rake::Task["mailer:work_statistics_report"].invoke
    Rake::Task["mailer:work_statistics_report"].reenable
  end
end
