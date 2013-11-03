# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

set :output, "#{path}/log/cron.log"

# Create alerts by filtering API responses and mail them
# Delete resolved alerts
# Delete API request information, keeping the last 10,000 requests
# Delete API response information, keeping responses from the last 24 hours
every 1.day, at: "4:00 AM" do
  rake "filter:all"
  rake "mailer:all"
  rake "queue:start"

  rake "db:alerts:delete"
  rake "db:api_requests:delete"
  rake "db:api_responses:delete"
end

# Learn more: http://github.com/javan/whenever
