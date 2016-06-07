# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# load ENV variables from .env file if it exists
env_file = File.expand_path("../../.env", __FILE__)
if File.exist?(env_file)
  require 'dotenv'
  Dotenv.load! env_file
end

env :PATH, ENV['PATH']
set :environment, ENV['RAILS_ENV']
set :output, "log/cron.log"

# Schedule jobs
# Send report when workers are not running
# Create notifications by filtering API responses and mail them
# Delete resolved notifications
# Delete API request information, keeping the last 1,000 requests
# Delete API response information, keeping responses from the last 24 hours
# Generate a monthly report

# every hour at 5 min past the hour
every "5 * * * *" do
  rake "cron:hourly"
end

every 1.day, at: "1:20 AM" do
  rake "cron:daily"
end

every :monday, at: "1:40 AM" do
  rake "cron:weekly"
end

# every 10th of the month at 2:10 AM
every "50 2 10 * *" do
  rake "cron:monthly"
end

# Learn more: http://github.com/javan/whenever
