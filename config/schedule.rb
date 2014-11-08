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

every 60.minutes do
  rake "queue:stale"
  rake "cache:update"
  rake "workers:monitor"
end

every 1.day, at: "1:00 AM" do
  rake "db:articles:import" if ENV['MEMBER']
  rake "filter:all"
  rake "mailer:error_report"
  rake "mailer:stale_source_report"

  rake "db:api_requests:delete"
  rake "db:api_responses:delete"
  rake "db:alerts:resolve"
end

every :monday, at: "1:30 AM" do
  rake "mailer:status_report"
  rake "f1000:update"
  rake "db:alerts:delete"
end

# every 9th of the month at 2 AM
every '0 2 9 * *' do
  rake "pmc:update"
end

# every 10th of the month at 5 AM
every '0 5 10 * *' do
  rake "report:all_stats"
  rake "mailer:article_statistics_report"
end

# Learn more: http://github.com/javan/whenever
