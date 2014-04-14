# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

set :environment, ENV['RAILS_ENV']
set :output, "log/cron.log"

# Schedule jobs
# Send report when workers are not running
# Create alerts by filtering API responses and mail them
# Delete resolved alerts
# Delete API request information, keeping the last 1,000 requests
# Delete API response information, keeping responses from the last 24 hours
# Generate a monthly report

every 10.minutes do
  rake "queue:stale"
end

every 4.hours do
  rake "workers:monitor"
end

every 1.day, at: "4:00 AM" do
  rake "filter:all"
  rake "mailer:error_report"
  rake "mailer:stale_source_report"

  rake "db:api_requests:delete"
  rake "db:api_responses:delete"
  rake "db:alerts:delete"
end

every :monday, at: "4:30 AM" do
  rake "mailer:status_report"
end

# every 10th of the month at 5 AM
every '0 5 10 * *' do
  rake "report:all_stats"
  rake "mailer:article_statistics_report"
end

# Learn more: http://github.com/javan/whenever
