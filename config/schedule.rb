# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

set :output, "#{path}/log/cron.log"

# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
#

# Create alerts by filtering API responses
every 1.day, at: "3:00 AM" do
  rake "filter:all"
end

# Delete resolved alerts
# Delete API request information, keeping the last 10,000 requests
every :monday, at: "4:00 AM" do
  rake "db:alerts:delete"
  rake "db:api_requests:delete"
end

# Learn more: http://github.com/javan/whenever
