# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

begin
  # make sure DOTENV is set
  ENV["DOTENV"] ||= "default"

  # load ENV variables from file specified by DOTENV
  # use .env with DOTENV=default
  filename = ENV["DOTENV"] == "default" ? ".env" : ".env.#{ENV['DOTENV']}"

  fail Errno::ENOENT unless File.exist?(File.expand_path("../../#{filename}", __FILE__))

  # load ENV variables from file specified by APP_ENV, fallback to .env
  require "dotenv"
  Dotenv.load! filename
rescue Errno::ENOENT
  $stderr.puts "Please create file .env in the Rails root folder"
  exit
rescue LoadError
  $stderr.puts "Please install dotenv with \"gem install dotenv\""
  exit
end

env :PATH, ENV['PATH']
env :DOTENV, ENV['DOTENV']
set :environment, ENV['RAILS_ENV']
set :output, "log/cron.log"

# Schedule jobs
# Send report when workers are not running
# Create alerts by filtering API responses and mail them
# Delete resolved alerts
# Delete API request information, keeping the last 1,000 requests
# Delete API response information, keeping responses from the last 24 hours
# Generate a monthly report

# every hour at 10 min past the hour
every "10 * * * *" do
  rake "cron:hourly"
end

every 1.day, at: "1:20 AM" do
  rake "cron:daily"
end

every "20 11,16 * * *" do
  rake "cron:import", :output => "log/cron_import.log"
end

every :monday, at: "1:40 AM" do
  rake "cron:weekly"
end

# every 10th of the month at 2:10 AM
every "50 2 10 * *" do
  rake "cron:monthly"
end

# Learn more: http://github.com/javan/whenever
