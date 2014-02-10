# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

set :output, "#{path}/log/cron.log"

# Create alerts by filtering API responses and mail them
# Restart worker queues in case they got stuck
# Delete resolved alerts
# Delete API request information, keeping the last 1,000 requests
# Delete API response information, keeping responses from the last 24 hours
# Generate a monthly report
every 1.day, at: "4:00 AM" do
  rake "filter:all"
  rake "mailer:error_report"
  rake "queue:start"

  rake "db:api_requests:delete"
  rake "db:api_responses:delete"
end

every :monday, at: "4:30 AM" do
  rake "mailer:status_report"
  rake "db:alerts:delete"
end

# every 10th of the month at 5 AM
every '0 5 10 * *' do
  rake "report:all_stats"
  rake "mailer:article_statistics_report"
end

# Learn more: http://github.com/javan/whenever
